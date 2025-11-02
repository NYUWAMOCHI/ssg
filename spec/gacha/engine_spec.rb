# frozen_string_literal: true

require "spec_helper"

RSpec.describe SSG::Gacha::Engine do
  let(:common_card) { GachaCard.new(id: 1, name: "Common", rarity: "common", weight: 70) }
  let(:rare_card) { GachaCard.new(id: 2, name: "Rare", rarity: "rare", weight: 25) }
  let(:sr_card) { GachaCard.new(id: 3, name: "SR", rarity: "super_rare", weight: 4) }
  let(:ur_card) { GachaCard.new(id: 4, name: "UR", rarity: "ultra_rare", weight: 1) }

  let(:all_cards) { [common_card, rare_card, sr_card, ur_card] }
  let(:cards_relation) { GachaCardRelation.new(all_cards) }

  describe "#initialize" do
    it "accepts a relation-like object" do
      expect { described_class.new(cards_relation) }.not_to raise_error
    end

    it "raises error with empty cards" do
      empty_relation = GachaCardRelation.new([])
      expect { described_class.new(empty_relation) }.to raise_error(ArgumentError, "Cards cannot be empty")
    end

    it "raises error when cards don't respond to weight" do
      invalid_card = double("InvalidCard")
      invalid_relation = GachaCardRelation.new([invalid_card])
      expect do
        described_class.new(invalid_relation)
      end.to raise_error(ArgumentError, "All cards must respond to :weight")
    end

    it "raises error when weights are not positive" do
      invalid_card = GachaCard.new(id: 5, name: "Invalid", rarity: "invalid", weight: 0)
      invalid_relation = GachaCardRelation.new([invalid_card])
      expect { described_class.new(invalid_relation) }.to raise_error(ArgumentError, "All weights must be positive")
    end
  end

  describe "#draw" do
    it "returns a card instance" do
      engine = described_class.new(cards_relation)
      result = engine.draw
      expect(result).to be_a(GachaCard)
    end

    it "returns a card from the provided cards" do
      engine = described_class.new(cards_relation)
      result = engine.draw
      expect(all_cards).to include(result)
    end

    it "respects weight distribution" do
      engine = described_class.new(cards_relation)
      results = 1000.times.map { engine.draw.name }

      common_count = results.count("Common")
      expect(common_count).to be_between(600, 800)
    end
  end

  describe "#draw_multiple" do
    it "returns specified number of cards" do
      engine = described_class.new(cards_relation)
      results = engine.draw_multiple(10)
      expect(results.size).to eq(10)
    end

    it "returns all cards as instances" do
      engine = described_class.new(cards_relation)
      results = engine.draw_multiple(5)
      expect(results).to all(be_a(GachaCard))
    end
  end

  describe "#probabilities" do
    it "returns correct probabilities" do
      engine = described_class.new(cards_relation)
      probs = engine.probabilities

      expect(probs[common_card.id]).to eq(70.0)
      expect(probs[rare_card.id]).to eq(25.0)
      expect(probs[sr_card.id]).to eq(4.0)
      expect(probs[ur_card.id]).to eq(1.0)
    end

    it "sums to 100" do
      engine = described_class.new(cards_relation)
      probs = engine.probabilities
      total = probs.values.sum
      expect(total).to eq(100.0)
    end
  end
end
