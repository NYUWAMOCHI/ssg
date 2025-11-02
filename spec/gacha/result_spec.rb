# frozen_string_literal: true

require "spec_helper"

RSpec.describe SSG::Gacha::Result do
  let(:card) { GachaCard.new(id: 1, name: "Test Card", rarity: "rare", weight: 10) }

  describe "#initialize" do
    it "accepts a card object" do
      expect { described_class.new(card) }.not_to raise_error
    end

    it "stores the card" do
      result = described_class.new(card)
      expect(result.card).to eq(card)
    end
  end

  describe "#name" do
    it "returns the card's name" do
      result = described_class.new(card)
      expect(result.name).to eq("Test Card")
    end
  end

  describe "#rarity" do
    it "returns the card's rarity" do
      result = described_class.new(card)
      expect(result.rarity).to eq("rare")
    end
  end

  describe "#json_format" do
    it "returns a hash with card information" do
      result = described_class.new(card)
      hash = result.json_format

      expect(hash).to be_a(Hash)
      expect(hash[:card_id]).to eq(1)
      expect(hash[:name]).to eq("Test Card")
      expect(hash[:rarity]).to eq("rare")
    end

    it "includes all required keys" do
      result = described_class.new(card)
      hash = result.json_format

      expect(hash.keys).to contain_exactly(:card_id, :name, :rarity)
    end
  end

  describe "attr_reader" do
    it "has read-only card attribute" do
      result = described_class.new(card)
      expect do
        result.card = GachaCard.new(id: 2, name: "Other", rarity: "common", weight: 5)
      end.to raise_error(NoMethodError)
    end
  end
end
