# frozen_string_literal: true

class Edge
  include Comparable

  attr_reader :source, :destination, :weight

  def initialize(source:, destination:, weight:)
    @source = source
    @destination = destination
    @weight = weight

    # A bit leaky, but acceptable given the interdependence
    source.add_outgoing_edge(self)
    destination.add_incoming_edge(self)
  end

  def <=>(other)
    @weight - other.weight
  end

  def to_s
    "#{@source.id}#{@destination.id}#{@weight}"
  end
end
