#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'models/graph'

GRAPH_FIXTURE = './config/graph.txt'

graph = Graph.from_file(GRAPH_FIXTURE)
puts graph

