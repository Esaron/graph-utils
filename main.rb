#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pry-byebug'

require_relative 'models/graph'

GRAPH_FIXTURE = './config/graph.txt'

graph = Graph.from_file(GRAPH_FIXTURE)
puts graph.distance('A', 'B', 'C')
puts graph.distance('A', 'D')
puts graph.distance('A', 'D', 'C')
puts graph.distance('A', 'E', 'B', 'C', 'D')
puts graph.distance('A', 'E', 'D')
# count of routes from C to C with max 3 hops
puts graph.paths('C', 'C') { |path, _weight| path.size <= 4 }.count
# count of routes from A to C with exactly 4 hops
puts(
  graph.paths('A', 'C') { |path, _weight| path.size <= 5 }.count do |path|
    path.path.size == 5
  end
)
puts graph.shortest_path('A', 'C').weight
puts graph.shortest_path('B', 'B', force_hops: true).weight
# count of routes from foo to bar with distance less than baz
puts graph.paths('C', 'C') { |_path, weight| weight < 30 }.count
