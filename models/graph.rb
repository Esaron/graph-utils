# frozen_string_literal: true

class Graph
  attr_reader :edges, :vertices

  # [v1][v2][weight], [v2][v3][weight], ..., [v4][v5][weight]
  # Additional formats could include json, yaml, etc.
  def self.from_file(filename)
    input = File.read(filename)
    graph = Graph.new
    edges = input.strip.split(', ')
    edges.each do |edge|
      # An assumption is that each vertex's unique id is only one character
      graph.add_edge(source: graph.add_vertex(edge[0]),
                     destination: graph.add_vertex(edge[1]),
                     weight: edge[2..-1])
    end
    graph
  end

  def initialize
    @edges = []
    @vertices = {}
  end

  def add_vertex(id)
    @vertices[id] ||= Vertex.new(id)
  end

  def add_edge(source:, destination:, weight:)
    @edges << Edge.new(source: source, destination: destination, weight: weight)
  end
end
