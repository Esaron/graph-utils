# frozen_string_literal: true

class Vertex
  attr_reader :id, :incoming_edges, :outgoing_edges

  def initialize(id)
    @id = id
    @incoming_edges = []
    @outgoing_edges = []
  end

  # Fluent, just because
  def add_incoming_edge(edge)
    @incoming_edges << edge
    self
  end

  def add_outgoing_edge(edge)
    @outgoing_edges << edge
    self
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

  def to_s
    @id.to_s
  end
end
