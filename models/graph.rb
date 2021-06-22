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
    @shortest_paths = Hash.new({})
  end

  def add_vertex(id)
    # Memoization makes sense for the problem I'm working on
    @vertices[id] ||=
      begin
        # Bust the Dijkstra cache so we aren't relying on
        # a potentially stale data
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

  private

  def dijkstra(source) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    vertex_set = Set.new(@vertices.values)
    @vertices.each_value do |vertex|
      @shortest_paths[source.id][vertex.id] =
        Path.new(source: source, destination: vertex)
    end
    @shortest_paths[source.id][source.id] =
      Path.new(source: source, destination: source, weight: 0)

    until vertex_set.empty?
      relevant_paths = @shortest_paths[source.id].filter do |_k, v|
        vertex_set.include?(v.destination)
      end
      nearest = relevant_paths.values.min
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
  end

  def bust_dijkstra_cache
    @shortest_paths = Hash.new({})
  end

  def edge_key(source, destination)
    Digest::SHA1.hexdigest "#{source}#{destination}"
  end
end
