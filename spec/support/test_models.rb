# frozen_string_literal: true

# Test model for Gacha card
class GachaCard
  attr_accessor :id, :name, :rarity, :weight

  def initialize(id:, name:, rarity:, weight:)
    @id = id
    @name = name
    @rarity = rarity
    @weight = weight
  end
end

# Test relation for Gacha cards
class GachaCardRelation
  @all_cards = []

  attr_accessor :cards

  def initialize(cards = [])
    @cards = cards
  end

  def to_a
    @cards
  end

  def self.all
    new(@all_cards || [])
  end

  class << self
    attr_writer :all_cards
  end

  def self.delete_all
    @all_cards = []
  end
end
