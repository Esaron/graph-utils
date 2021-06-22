# frozen_string_literal: true

class Vertex
  attr_reader :id, :incoming_edges, :outgoing_edges, :children, :parents

  def initialize(id, incoming_edges: [], outgoing_edges: [])
    @id = id
    @incoming_edges = incoming_edges
    @outgoing_edges = outgoing_edges
    @children = @outgoing_edges.map(&:destination)
    @parents = @incoming_edges.map(&:source)
  end

  def add_incoming_edge(edge)
    @parents << edge.source
    @incoming_edges << edge
  end

  def add_outgoing_edge(edge)
    @children << edge.destination
    @outgoing_edges << edge
  end
end
