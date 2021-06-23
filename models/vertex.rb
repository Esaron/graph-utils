# frozen_string_literal: true

require_relative 'path'

class Vertex
  attr_reader :id, :incoming_edges, :outgoing_edges

  def initialize(id)
    @id = id
    @incoming_edges = []
    @outgoing_edges = []
    @parents = nil
    @children = nil
  end

  # Fluent, just because
  def add_incoming_edge(edge)
    @incoming_edges << edge
    @parents = nil
    self
  end

  def add_outgoing_edge(edge)
    @outgoing_edges << edge
    @children = nil
    self
  end

  def distance(destination)
    edge = @outgoing_edges.find do |outgoing|
      outgoing.destination == destination
    end
    raise NoSuchRouteError if edge.nil?

    edge.weight
  end

  # This is ugly and should be rewritten. It's a recursive implementation
  # that relies on a stopping condition passed as a block to satisfy some
  # of the requirements. There are too many arguments and the functionality
  # allowed by the block could be better implemented as options and/or more
  # specific method implementations.
  # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
  def paths(destination_id,
            source: self,
            weight: 0,
            prev_path: [],
            results: [],
            &block)
    @outgoing_edges.each do |edge|
      child = edge.destination
      path = [source] + prev_path
      total_weight = weight + edge.weight
      if block.nil?
        next if path.include?(child)
      else
        next unless yield path + [child], total_weight
      end

      if child.id == destination_id
        results << Path.new(source: source,
                            destination: child,
                            path: path,
                            weight: total_weight)
      end

      child.paths(destination_id,
                  source: source,
                  weight: total_weight,
                  prev_path: prev_path + [child],
                  results: results,
                  &block)
    end

    results
  end
  # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists

  def hash
    # We expect alphanumeric, case-insensitive ids, so we use base 36
    # (digits + a-z)
    Integer(@id, 36)
  end

  def ==(other)
    @id == other.id
  end
  alias eql? ==

  def to_s
    @id.to_s
  end

  NoSuchRouteError = Class.new(StandardError)
end
