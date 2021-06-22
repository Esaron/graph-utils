# frozen_string_literal: true

require_relative '../../models/edge'

RSpec.describe Edge do
  let(:edge) do
    described_class.new(source: src, destination: dest, weight: weight)
  end

  let(:src_id) { 'Y' }
  let(:src) { Vertex.new(src_id) }
  let(:dest_id) { 'Z' }
  let(:dest) { Vertex.new(dest_id) }
  let(:weight) { 5 }

  describe '#<=>' do
    subject { edge <=> other }

    let(:other) { Edge.new(source: src, destination: dest, weight: other_weight) }

    context 'when the weights are equal' do
      let(:other_weight) { weight }

      it { is_expected.to be 0 }
    end

    context 'when the other weight is smaller' do
      let(:other_weight) { weight - 1 }

      it { is_expected.to be > 0 }
    end

    context 'when the other weight is bigger' do
      let(:other_weight) { weight + 1 }

      it { is_expected.to be < 0 }
    end
  end

  describe '#to_s' do
    subject { edge.to_s }

    it 'returns the source, destination, and weight concatenated together' do
      expect(subject).to eq('YZ5')
    end
  end
end
