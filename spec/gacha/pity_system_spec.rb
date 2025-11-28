# frozen_string_literal: true

require "spec_helper"

RSpec.describe SGK::Gacha::PitySystem do
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

    it "raises error with non-positive guarantee_limit" do
      expect do
        described_class.new(engine, guarantee_limit: 0)
      end.to raise_error(ArgumentError, "Guarantee limit must be positive")
    end

    it "raises error with negative guarantee_limit" do
      expect do
        described_class.new(engine, guarantee_limit: -10)
      end.to raise_error(ArgumentError, "Guarantee limit must be positive")
    end

    it "accepts custom guarantee_limit" do
      expect { described_class.new(engine, guarantee_limit: 50) }.not_to raise_error
    end

    it "accepts custom guaranteed_rarity" do
      expect { described_class.new(engine, guaranteed_rarity: :super_rare) }.not_to raise_error
    end

    it "converts guaranteed_rarity to symbol" do
      pity = described_class.new(engine, guaranteed_rarity: "ultra_rare")
      expect(pity.guaranteed_rarity).to be_a(Symbol)
    end
  end

  describe "#draw" do
    context "when pity count is below guarantee limit" do
      it "performs normal draw" do
        pity = described_class.new(engine)
        result = pity.draw(current_pity_count: 50)
        expect(result).to be_a(GachaCard)
      end

      it "can return any card type" do
        pity = described_class.new(engine)
        results = 1000.times.map { pity.draw(current_pity_count: 50) }
        rarities = results.map(&:rarity).uniq
        # With 1000 draws, we should get multiple rarity types
        expect(rarities.size).to be > 1
      end
    end

    context "when pity count reaches guarantee limit" do
      it "returns guaranteed card (UR)" do
        pity = described_class.new(engine, guarantee_limit: 100)
        result = pity.draw(current_pity_count: 100)
        expect(result.rarity).to eq("ultra_rare")
      end

      it "always returns UR when pity count is at limit" do
        pity = described_class.new(engine, guarantee_limit: 100)
        results = 10.times.map { pity.draw(current_pity_count: 100) }
        expect(results).to all(have_attributes(rarity: "ultra_rare"))
      end

      it "always returns guaranteed card when pity exceeds limit" do
        pity = described_class.new(engine, guarantee_limit: 100)
        result = pity.draw(current_pity_count: 150)
        expect(result.rarity).to eq("ultra_rare")
      end
    end

    context "with custom guarantee_limit" do
      it "respects custom guarantee limit" do
        pity = described_class.new(engine, guarantee_limit: 50)
        result = pity.draw(current_pity_count: 50)
        expect(result.rarity).to eq("ultra_rare")
      end
    end

    context "with custom guaranteed_rarity" do
      it "guarantees specified rarity" do
        pity = described_class.new(engine, guarantee_limit: 100, guaranteed_rarity: :super_rare)
        result = pity.draw(current_pity_count: 100)
        expect(result.rarity).to eq("super_rare")
      end
    end

    it "raises error with negative pity count" do
      pity = described_class.new(engine)
      expect do
        pity.draw(current_pity_count: -1)
      end.to raise_error(ArgumentError, "Pity count must be non-negative")
    end

    it "accepts zero pity count" do
      pity = described_class.new(engine)
      expect { pity.draw(current_pity_count: 0) }.not_to raise_error
    end
  end

  describe "#draw_multiple" do
    it "returns specified number of cards" do
      pity = described_class.new(engine)
      results = pity.draw_multiple(10, current_pity_count: 0)
      expect(results.size).to eq(10)
    end

    it "returns all GachaCard instances" do
      pity = described_class.new(engine)
      results = pity.draw_multiple(5, current_pity_count: 0)
      expect(results).to all(be_a(GachaCard))
    end

    it "raises error with zero count" do
      pity = described_class.new(engine)
      expect do
        pity.draw_multiple(0, current_pity_count: 0)
      end.to raise_error(ArgumentError, "Draw count must be positive")
    end

    it "raises error with negative count" do
      pity = described_class.new(engine)
      expect do
        pity.draw_multiple(-5, current_pity_count: 0)
      end.to raise_error(ArgumentError, "Draw count must be positive")
    end

    it "raises error with negative pity count" do
      pity = described_class.new(engine)
      expect do
        pity.draw_multiple(10, current_pity_count: -1)
      end.to raise_error(ArgumentError, "Pity count must be non-negative")
    end

    context "when pity reaches guarantee during draws" do
      it "guarantees card at 100th draw" do
        pity = described_class.new(engine, guarantee_limit: 100)
        # Start at 95, draw 10 times (95-104)
        results = pity.draw_multiple(10, current_pity_count: 95)
        expect(results.size).to eq(10)
        # At least the 6th draw (at index 5) should be UR (when count reaches 100)
        expect(results[5].rarity).to eq("ultra_rare")
      end

      it "resets pity count after guaranteed card" do
        pity = described_class.new(engine, guarantee_limit: 5)
        # Start at 3, draw 10 times
        # Draws: 3(no), 4(no), 5(GUARANTEED), 0(reset), 1, 2, 3, 4, 5(GUARANTEED), 0(reset)
        results = pity.draw_multiple(10, current_pity_count: 3)

        # After drawing 10 times starting from 3, we should have 2 guaranteed cards
        ur_count = results.count { |card| card.rarity == "ultra_rare" }
        expect(ur_count).to eq(2)
      end
    end

    context "starting exactly at guarantee limit" do
      it "first card is guaranteed" do
        pity = described_class.new(engine, guarantee_limit: 100)
        results = pity.draw_multiple(5, current_pity_count: 100)
        expect(results.first.rarity).to eq("ultra_rare")
      end
    end
  end

  describe "#next_guarantee_info" do
    it "returns hash with guarantee information" do
      pity = described_class.new(engine, guarantee_limit: 100)
      info = pity.next_guarantee_info(current_pity_count: 75)

      expect(info).to be_a(Hash)
      expect(info.keys).to include(:current_pity_count, :remaining, :guaranteed_at)
    end

    it "calculates correct remaining draws" do
      pity = described_class.new(engine, guarantee_limit: 100)
      info = pity.next_guarantee_info(current_pity_count: 75)

      expect(info[:current_pity_count]).to eq(75)
      expect(info[:remaining]).to eq(25)
      expect(info[:guaranteed_at]).to eq(100)
    end

    it "returns zero remaining when at limit" do
      pity = described_class.new(engine, guarantee_limit: 100)
      info = pity.next_guarantee_info(current_pity_count: 100)
      expect(info[:remaining]).to eq(0)
    end

    it "returns zero remaining when beyond limit" do
      pity = described_class.new(engine, guarantee_limit: 100)
      info = pity.next_guarantee_info(current_pity_count: 150)
      expect(info[:remaining]).to eq(0)
    end

    it "works with custom guarantee_limit" do
      pity = described_class.new(engine, guarantee_limit: 50)
      info = pity.next_guarantee_info(current_pity_count: 30)

      expect(info[:remaining]).to eq(20)
      expect(info[:guaranteed_at]).to eq(50)
    end

    it "raises error with negative pity count" do
      pity = described_class.new(engine)
      expect do
        pity.next_guarantee_info(current_pity_count: -1)
      end.to raise_error(ArgumentError, "Pity count must be non-negative")
    end
  end

  describe "attr_readers" do
    it "returns the engine" do
      pity = described_class.new(engine)
      expect(pity.engine).to eq(engine)
    end

    it "returns the guarantee_limit" do
      pity = described_class.new(engine, guarantee_limit: 50)
      expect(pity.guarantee_limit).to eq(50)
    end

    it "returns the guaranteed_rarity" do
      pity = described_class.new(engine, guaranteed_rarity: :super_rare)
      expect(pity.guaranteed_rarity).to eq(:super_rare)
    end
  end

  describe "edge cases" do
    context "with only guaranteed rarity cards" do
      it "handles single card type" do
        ur_only = GachaCardRelation.new([ur_card])
        ur_engine = SGK::Gacha::Engine.new(ur_only)
        pity = described_class.new(ur_engine)

        result = pity.draw(current_pity_count: 100)
        expect(result.rarity).to eq("ultra_rare")
      end
    end

    context "with pity_count = 0" do
      it "performs normal draw" do
        pity = described_class.new(engine)
        result = pity.draw(current_pity_count: 0)
        expect(result).to be_a(GachaCard)
      end
    end

    context "multiple guarantee events in sequence" do
      it "tracks pity correctly through multiple guarantees" do
        pity = described_class.new(engine, guarantee_limit: 5)

        # Draw 20 times starting from 0
        # With guarantee_limit: 5, we should get guaranteed URs at position 4, 9, 14, 19
        results = pity.draw_multiple(20, current_pity_count: 0)
        ur_count = results.count { |card| card.rarity == "ultra_rare" }

        # Should have at least 3 guaranteed URs (at positions 4, 9, 14)
        expect(ur_count).to be >= 3
      end
    end
  end
end
