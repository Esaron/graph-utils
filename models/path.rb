# frozen_string_literal: true

require 'bigdecimal'

class Path
  include Comparable

  attr_reader :source, :destination
  attr_accessor :weight

  def initialize(source:, destination:, path: [], weight: BigDecimal::INFINITY)
    @source = source
    @destination = destination
    @path = path
    @weight = weight
  end

  def path
    @path + [destination]
  end

  def update(path, weight)
    @path = path
    @weight = weight
  end

  def <=>(other)
    @weight - other.weight
  end
end
