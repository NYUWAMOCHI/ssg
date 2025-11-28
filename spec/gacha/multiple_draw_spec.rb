# frozen_string_literal: true

require "spec_helper"

RSpec.describe SGK::Gacha::MultipleDraw do
  let(:common_card) { GachaCard.new(id: 1, name: "Common", rarity: "common", weight: 70) }
  let(:rare_card) { GachaCard.new(id: 2, name: "Rare", rarity: "rare", weight: 25) }
  let(:sr_card) { GachaCard.new(id: 3, name: "SR", rarity: "super_rare", weight: 4) }
  let(:ur_card) { GachaCard.new(id: 4, name: "UR", rarity: "ultra_rare", weight: 1) }

  let(:all_cards) { [common_card, rare_card, sr_card, ur_card] }
  let(:cards_relation) { GachaCardRelation.new(all_cards) }
  let(:engine) { SGK::Gacha::Engine.new(cards_relation) }

  describe "#initialize" do
    it "accepts a valid engine" do
      expect { described_class.new(engine) }.not_to raise_error
    end

    it "raises error when engine is not SGK::Gacha::Engine" do
      expect do
        described_class.new("invalid_engine")
      end.to raise_error(ArgumentError, "Engine must be a SGK::Gacha::Engine instance")
    end

    it "accepts custom draw_count" do
      expect { described_class.new(engine, draw_count: 5) }.not_to raise_error
    end

    it "raises error with zero draw_count" do
      expect do
        described_class.new(engine, draw_count: 0)
      end.to raise_error(ArgumentError, "Draw count must be positive")
    end

    it "raises error with negative draw_count" do
      expect do
        described_class.new(engine, draw_count: -5)
      end.to raise_error(ArgumentError, "Draw count must be positive")
    end

    it "uses default draw count of 10" do
      drawer = described_class.new(engine)
      expect(drawer.draw_count).to eq(10)
    end
  end

  describe "#execute" do
    it "returns array of cards" do
      drawer = described_class.new(engine)
      results = drawer.execute
      expect(results).to be_a(Array)
    end

    it "returns correct number of cards" do
      drawer = described_class.new(engine, draw_count: 10)
      results = drawer.execute
      expect(results.size).to eq(10)
    end

    it "returns GachaCard instances" do
      drawer = described_class.new(engine)
      results = drawer.execute
      expect(results).to all(be_a(GachaCard))
    end

    it "supports custom draw counts" do
      drawer = described_class.new(engine, draw_count: 5)
      results = drawer.execute
      expect(results.size).to eq(5)
    end

    it "supports 1-draw" do
      drawer = described_class.new(engine, draw_count: 1)
      results = drawer.execute
      expect(results.size).to eq(1)
      expect(results.first).to be_a(GachaCard)
    end

    it "supports large draw counts" do
      drawer = described_class.new(engine, draw_count: 100)
      results = drawer.execute
      expect(results.size).to eq(100)
      expect(results).to all(be_a(GachaCard))
    end
  end

  describe "#draw" do
    it "is an alias for execute" do
      drawer = described_class.new(engine)
      results1 = drawer.draw
      results2 = drawer.execute

      # Both should return arrays of the same size
      expect(results1.size).to eq(results2.size)
      expect(results1.size).to eq(10)
    end

    it "returns array of cards" do
      drawer = described_class.new(engine)
      results = drawer.draw
      expect(results).to be_a(Array)
      expect(results.size).to eq(10)
    end
  end

  describe "attr_readers" do
    it "returns the engine" do
      drawer = described_class.new(engine)
      expect(drawer.engine).to eq(engine)
    end

    it "returns the draw_count" do
      drawer = described_class.new(engine, draw_count: 15)
      expect(drawer.draw_count).to eq(15)
    end
  end

  describe "default draw count" do
    it "has a default draw count of 10" do
      expect(described_class::DEFAULT_DRAW_COUNT).to eq(10)
    end

    it "uses the constant for default initialization" do
      drawer = described_class.new(engine)
      expect(drawer.draw_count).to eq(described_class::DEFAULT_DRAW_COUNT)
    end
  end

  describe "weight distribution" do
    it "respects weight distribution over many draws" do
      drawer = described_class.new(engine, draw_count: 1000)
      results = drawer.execute
      common_count = results.count { |card| card.rarity == "common" }

      # With 1000 draws, common (weight 70) should appear around 700 times
      expect(common_count).to be_between(600, 800)
    end
  end

  describe "edge cases" do
    it "works with single card type" do
      ur_only = GachaCardRelation.new([ur_card])
      ur_engine = SGK::Gacha::Engine.new(ur_only)
      drawer = described_class.new(ur_engine, draw_count: 5)

      results = drawer.execute
      expect(results).to all(have_attributes(rarity: "ultra_rare"))
    end

    it "handles 100-draw (10連の10倍)" do
      drawer = described_class.new(engine, draw_count: 100)
      results = drawer.execute
      expect(results.size).to eq(100)
    end
  end
end
