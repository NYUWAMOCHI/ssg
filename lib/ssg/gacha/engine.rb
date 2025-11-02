# frozen_string_literal: true

module SSG
  module Gacha
    # Gacha engine that implements weighted random card selection.
    #
    # This engine takes an ActiveRecord relation of cards and provides methods
    # to draw cards based on their weights, supporting both single draws and
    # multiple draws in one operation.
    class Engine
      def initialize(card_relation)
        @cards = card_relation.to_a
        validate_cards!
        @total_weight = @cards.sum(&:weight)
      end

      def draw
        return nil if @cards.empty?

        random_value = rand(0...@total_weight)
        current_sum = 0

        @cards.each do |card|
          current_sum += card.weight
          return card if random_value < current_sum
        end

        # NOTE: 浮動小数点誤差を考慮して最後のカードを返す実装だが、重み付き抽選の特性上起こる可能性はほとんどない。
        # Returns the last card as a fallback for floating-point precision errors,
        # though this scenario is highly unlikely given the nature of weighted random selection.
        @cards.last
      end

      def draw_multiple(count)
        Array.new(count) { draw }
      end

      def probabilities
        result = {}
        @cards.each do |card|
          result[card.id] = (card.weight.to_f / @total_weight * 100).round(2)
        end
        result
      end

      private

      def validate_cards!
        raise ArgumentError, "Cards cannot be empty" if @cards.empty?
        raise ArgumentError, "All cards must respond to :weight" unless @cards.all? { |card| card.respond_to?(:weight) }
        raise ArgumentError, "All weights must be positive" unless @cards.all? { |card| card.weight.positive? }
      end
    end
  end
end
