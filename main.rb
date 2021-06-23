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
puts graph.shortest_path('A', 'C').weight
puts graph.shortest_path('A', 'C').path.map(&:id)
puts graph.shortest_path('B', 'B').weight
puts graph.shortest_path('B', 'B').path.map(&:id)
