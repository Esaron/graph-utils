#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pry-byebug'

require_relative 'models/graph'

GRAPH_FIXTURE = './config/graph.txt'

graph = Graph.from_file(GRAPH_FIXTURE)
puts graph.shortest_path('A', 'A').weight
puts graph.shortest_path('A', 'A').path.map(&:id)
