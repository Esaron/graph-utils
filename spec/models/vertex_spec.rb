# frozen_string_literal: true

require_relative '../../models/vertex'

RSpec.describe Vertex do
  let(:vertex) do
    described_class.new(id)
  end

  let(:id) { 'A' }

  describe '#add_incoming_edge' do
    subject { vertex.add_incoming_edge(edge) }

    let(:edge) { double(:edge) }

    it 'adds the edge to the incoming edges' do
      expect(subject.incoming_edges).to include(edge)
    end
  end

  describe '#add_outgoing_edge' do
    subject { vertex.add_outgoing_edge(edge) }

    let(:edge) { double(:edge) }

    it 'adds the edge to the incoming edges' do
      expect(subject.outgoing_edges).to include(edge)
    end
  end

  describe '#distance' do
    subject { vertex.distance(other) }

    let(:other) { Vertex.new(other_id) }
    let(:other_id) { 'B' }

    it 'raises a NoSuchRouteError' do
      expect { subject }.to raise_error(Vertex::NoSuchRouteError)
    end

    context 'when there is a route to the other node' do
      let!(:edge) do
        Edge.new(source: vertex, destination: other, weight: weight)
      end
      let(:weight) { 4 }

      it 'returns the weight of the edge' do
        expect(subject).to eq(weight)
      end
    end
  end

  describe '#paths' do
    subject do
      vertex.paths(other_id)
            .map(&:path)
            .map { |path| path.map(&:id) }
    end

    let(:other_id) { 'B' }

    it 'returns an empty array' do
      expect(subject).to eq([])
    end

    context 'when there are routes to the other node' do
      let(:other1) { Vertex.new(other_id) }
      let(:other2) { Vertex.new('Z') }

      let!(:edge1) do
        Edge.new(source: vertex, destination: other1, weight: weight)
      end
      let!(:edge2) do
        Edge.new(source: vertex, destination: other2, weight: weight)
      end
      let!(:edge3) do
        Edge.new(source: other2, destination: other1, weight: weight)
      end
      let(:weight) { 4 }

      let(:expected_paths) do
        [%w[A B], %w[A Z B]]
      end

      it 'returns each path' do
        expect(subject).to eq(expected_paths)
      end

      context 'with a path size limit' do
        subject do
          vertex.paths(other_id) { |path, _weight| path.size <= 2 }
                .map(&:path)
                .map { |path| path.map(&:id) }
        end

        let(:expected_paths) do
          [%w[A B]]
        end

        it 'returns all paths from source to destination with <= 2 vertices' do
          expect(subject).to eq(expected_paths)
        end
      end

      context 'with a weight limit' do
        subject do
          vertex.paths(other_id) { |_path, weight| weight <= 4 }
                .map(&:path)
                .map { |path| path.map(&:id) }
        end

        let(:expected_paths) do
          [%w[A B]]
        end

        it 'returns all paths from source to destination with weight <= 10' do
          expect(subject).to eq(expected_paths)
        end
      end
    end
  end

  describe '#hash' do
    subject { vertex.hash }

    it 'returns the base 10 representation of the base 36 id' do
      expect(subject).to eq(10)
    end

    context 'when the id contains an unknown character' do
      let(:id) { '_' }

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#==' do
    subject { vertex == other }

    let(:other_id) { 'B' }
    let(:other) { Vertex.new(other_id) }

    context 'when the ids differ' do
      it { is_expected.to be false }
    end

    context 'when the ids match' do
      let(:other_id) { 'A' }

      it { is_expected.to be true }
    end
  end

  describe '#to_s' do
    subject { vertex.to_s }

    it 'returns the stringified id' do
      expect(subject).to eq(id.to_s)
    end
  end
end
