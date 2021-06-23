# frozen_string_literal: true

require_relative '../../models/path'
require_relative '../../models/vertex'
require 'pry-byebug'

RSpec.describe Path do
  let(:path) do
    described_class.new(source: src, destination: dest, weight: weight)
  end

  let(:src_id) { 'Y' }
  let(:src) { Vertex.new(src_id) }
  let(:dest_id) { 'Z' }
  let(:dest) { Vertex.new(dest_id) }
  let(:weight) { BigDecimal::INFINITY }

  describe '#path' do
    subject { path.path }

    it 'returns the destination only' do
      expect(subject).to eq([dest])
    end

    context 'when another edge has been added' do
      let(:hop_id) { 'A' }
      let(:hop) { Vertex.new(hop_id) }
      let(:edge_weight) { 1 }

      before do
        path.update([src, hop], edge_weight)
      end

      it 'returns the full path' do
        expect(subject).to eq([src, hop, dest])
      end
    end
  end

  describe '#update' do
    subject { path.update(prev_path, edge_weight) }

    let(:prev_path) { [src, hop] }
    let(:hop_id) { 'A' }
    let(:hop) { Vertex.new(hop_id) }
    let(:edge_weight) { 1 }

    it 'updates the path' do
      expect { subject }.to change { path.path }
        .from([dest])
        .to([src, hop, dest])
    end

    it 'updates the weight' do
      expect { subject }.to change { path.weight }
        .from(BigDecimal::INFINITY)
        .to(edge_weight)
    end

    context 'when the edge source matches the path source' do
      let(:prev_path) { [src] }

      it 'updates the path to include the source' do
        expect { subject }.to change { path.path }
          .from([dest])
          .to([src, dest])
      end

      it 'updates the weight' do
        expect { subject }.to change { path.weight }
          .from(BigDecimal::INFINITY)
          .to(edge_weight)
      end
    end
  end

  describe '#<=>' do
    subject { path <=> other }

    let(:other) do
      Path.new(source: src, destination: dest, weight: other_weight)
    end
    let(:other_weight) { weight }

    it 'returns NaN' do
      expect(subject.nan?).to be(true)
    end

    context 'with a calculated weight' do
      let(:weight) { 5 }

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
  end
end
