# frozen_string_literal: true

class Edge
  attr_reader :source, :destination, :weight

  def initialize(source:, destination:, weight:)
    @source = source
    @destination = destination
    @weight = weight

    source.add_outgoing_edge(self)
    destination.add_incoming_edge(self)
  end

  def <=>(b)
    @weight - b.weight
  end
end
