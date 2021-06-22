# frozen_string_literal: true

class Vertex
  attr_reader :id, :incoming_edges, :outgoing_edges

  def initialize(id, incoming_edges: [], outgoing_edges: [])
    @id = id
    @incoming_edges = incoming_edges
    @outgoing_edges = outgoing_edges
  end

  def add_incoming_edge(edge)
    @incoming_edges << edge
  end

  def add_outgoing_edge(edge)
    @outgoing_edges << edge
  end

  def get_outgoing_edge(destination_id)
    @outgoing_edges.find { |edge| edge.destination.id == destination_id }
  end

  def hash
    # We expect alphanumeric, case-insensitive ids,so we use base 36
    # (digits + a-z)
    Integer(@id, 36)
  end

  def ==(other)
    @id == other.id
  end
  alias eql? ==
end
