# frozen_string_literal: true

require_relative '../../models/graph'

RSpec.describe Graph do
  let(:graph_fixture) { "#{__dir__}/../../config/graph.txt" }

  describe '.from_file' do
    subject { described_class.from_file(graph_fixture) }

    let(:expected_vertices) { %w[A B C D E] }
    let(:expected_edges) { %w[AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7] }

    it 'has vertices matching those in the fixture' do
      expect(subject.vertices.values.map(&:to_s)).to eq(expected_vertices)
    end

    it 'has edges matching those in the fixture' do
      expect(subject.edges.values.map(&:to_s)).to eq(expected_edges)
    end
  end

  context 'with a loaded graph' do
    let(:graph) { described_class.from_file(graph_fixture) }

    describe '#add_vertex' do
      subject { graph.add_vertex(id) }

      let(:id) { 'Z' }

      it 'adds the vertex to the graph' do
        expect { subject }.to change { graph.vertices[id] }.from(nil)
      end

      it 'busts the dijkstra cache' do
        expect(graph).to receive(:bust_dijkstra_cache)
        subject
      end

      context 'when a vertex with that id already exists' do
        before do
          subject
        end

        it 'does not add the vertex to the graph' do
          expect { subject }.not_to change { graph.vertices[id] }
        end

        it 'does not bust the dijkstra cache' do
          expect(graph).not_to receive(:bust_dijkstra_cache)
          subject
        end
      end
    end

    describe '#add_edge' do
      subject { graph.add_edge(source: src, destination: dest, weight: weight) }

      let(:src_id) { 'Y' }
      let(:src) { Vertex.new(src_id) }
      let(:dest_id) { 'Z' }
      let(:dest) { Vertex.new(dest_id) }
      let(:weight) { 1 }
      let(:edge_hash) { Digest::SHA1.hexdigest "#{src_id}#{dest_id}" }

      it 'adds the edge to the graph' do
        expect { subject }.to change { graph.edges[edge_hash] }.from(nil)
      end

      it 'busts the dijkstra cache' do
        expect(graph).to receive(:bust_dijkstra_cache)
        subject
      end

      context 'when an edge with that key already exists' do
        before do
          subject
        end

        it 'does not add the edge to the graph' do
          expect { subject }.not_to change { graph.edges[edge_hash] }
        end

        it 'does not bust the dijkstra cache' do
          expect(graph).not_to receive(:bust_dijkstra_cache)
          subject
        end
      end
    end

    describe '#shortest_path' do
      subject { graph.shortest_path(src_id, dest_id) }

      let(:src_id) { 'A' }
      let(:dest_id) { 'C' }

      it 'returns the correct weight' do
        expect(subject.weight).to eq(9)
      end

      it 'returns the correct path' do
        expect(subject.path.map(&:id)).to eq(%w[A B C])
      end

      context 'when a direct path is longer than an indirect one' do
        let(:graph_fixture) { "#{__dir__}/../fixtures/long_direct_route.txt" }

        it 'returns the correct weight' do
          expect(subject.weight).to eq(2)
        end

        it 'returns the correct path' do
          expect(subject.path.map(&:id)).to eq(%w[A B C])
        end
      end

      context 'when two paths are equally short' do
        let(:graph_fixture) { "#{__dir__}/../fixtures/two_equivalent_paths.txt" }

        it 'returns the correct weight' do
          expect(subject.weight).to eq(2)
        end

        it 'returns the first correct path' do
          expect(subject.path.map(&:id)).to eq(%w[A C])
        end
      end

      context 'when the graph has already cached values for a given source' do
        before do
          subject
        end

        it 'does not recompute the paths' do
          expect(graph).not_to receive(:dijkstra)
          subject
        end

        context 'when asking for a different path' do
          let(:dest_id) { 'D' }

          it 'does not recompute the paths' do
            expect(graph).not_to receive(:dijkstra)
            subject
          end
        end
      end
    end

    describe '#distance' do
      subject { graph.distance(src_id, *dest_ids) }

      let(:src_id) { 'A' }
      let(:dest_ids) { %w[B] }

      it 'returns the distance between src and destination' do
        expect(subject).to eq(5)
      end

      context 'with multiple hops' do
        let(:dest_ids) { %w[B C D] }

        it 'returns the distance between src and final destination' do
          expect(subject).to eq(17)
        end
      end
    end
  end
end
