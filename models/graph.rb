# frozen_string_literal: true

require 'digest'
require 'set'

require_relative 'edge'
require_relative 'path'
require_relative 'vertex'

class Graph
  attr_reader :edges, :vertices

  # [v1][v2][weight], [v2][v3][weight], ..., [v4][v5][weight]
  # Additional formats could include json, yaml, etc.
  def self.from_file(filename)
    input = File.read(filename)
    graph = Graph.new
    edges = input.strip.split(', ')
    edges.each do |edge|
      # An assumption is that each vertex's unique id is only one
      # case-insensitive alphanumeric character
      graph.add_edge(source: graph.add_vertex(edge[0]),
                     destination: graph.add_vertex(edge[1]),
                     weight: edge[2..].to_i)
    end
    graph
  end

  def initialize
    @edges = {}
    @vertices = {}
    # Dijkstra cache
    bust_dijkstra_cache
  end

  def add_vertex(id)
    # Memoization makes sense for the problem I'm working on
    @vertices[id] ||=
      begin
        # Bust the Dijkstra cache so we aren't relying on
        # potentially stale data
        bust_dijkstra_cache
        Vertex.new(id)
      end
  end

  def add_edge(source:, destination:, weight:)
    @edges[edge_key(source, destination)] ||=
      begin
        bust_dijkstra_cache
        Edge.new(source: source,
                 destination: destination,
                 weight: weight)
      end
  end

  def shortest_path(source_id, destination_id)
    cached_path = @shortest_paths.dig(source_id, destination_id)
    return cached_path if cached_path

    dijkstra(@vertices[source_id])

    @shortest_paths.dig(source_id, destination_id)
  end

  def distance(source_id, *hop_ids)
    source = @vertices[source_id]
    prev = source
    hop_ids.reduce(0) do |memo, hop_id|
      hop = @vertices[hop_id]
      memo += prev.distance(hop)
      prev = hop
      memo
    end
  rescue Vertex::NoSuchRouteError
    'NO SUCH ROUTE'
  end

  private

  def dijkstra(source, force_hops: true)
    initialize_paths(source)
    populate_paths(source)
    return unless force_hops

    # This is less than ideal... In order to force recalculation of
    # source-to-source paths, we just run the algorithm again after
    # clearing out the source-to-source path. If I had some more time I'd
    # optimize this, but I'm more focused on a working solution right now.
    # Technically the same big O performance, although in practical terms
    # it's 2x time.
    @shortest_paths[source.id][source.id] =
      Path.new(source: source, destination: source)
    populate_paths(source)
  end

  def initialize_paths(source)
    @shortest_paths[source.id] ||= {}
    @vertices.each_value do |vertex|
      @shortest_paths[source.id][vertex.id] =
        Path.new(source: source, destination: vertex)
    end
    @shortest_paths[source.id][source.id] =
      Path.new(source: source, destination: source, weight: 0)
  end

  def populate_paths(source)
    vertex_set = Set.new(@vertices.values)
    until vertex_set.empty?
      relevant_paths = @shortest_paths[source.id].filter do |_k, v|
        vertex_set.include?(v.destination)
      end
      nearest = relevant_paths.values.min
      calculate_hop(source, nearest, vertex_set)
    end
  end

  def calculate_hop(source, nearest, vertex_set)
    destination = nearest.destination
    vertex_set.delete(destination)
    relevant_edges = destination.outgoing_edges.filter do |edge|
      vertex_set.include?(edge.destination)
    end
    relevant_edges.each do |edge|
      weight = nearest.weight + edge.weight
      if weight < @shortest_paths[source.id][edge.destination.id].weight
        @shortest_paths[source.id][edge.destination.id].add_hop(edge, weight)
      end
    end
  end

  def bust_dijkstra_cache
    @shortest_paths = {}
  end

  def edge_key(source, destination)
    Digest::SHA1.hexdigest "#{source}#{destination}"
  end
end
