# frozen_string_literal: true

require 'bigdecimal'

class Path
  include Comparable

  attr_reader :source, :destination
  attr_accessor :weight

  def initialize(source:, destination:, weight: BigDecimal::INFINITY)
    @source = source
    @destination = destination
    @path = [source]
    @weight = weight
  end

  def path
    @path + [destination]
  end

  def <<(edge)
    # Avoid adding source twice in the case of direct routes
    @path << edge.source if @path.last != edge.source
  end

  def <=>(b)
    @weight - b.weight
  end
end
