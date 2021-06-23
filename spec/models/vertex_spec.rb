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
      let(:edge) do
        Edge.new(source: vertex, destination: other, weight: weight)
      end
      let(:weight) { 4 }

      before do
        vertex.add_outgoing_edge(edge)
      end

      it 'returns the weight of the edge' do
        expect(subject).to eq(weight)
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
