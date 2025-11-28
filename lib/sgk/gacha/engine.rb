# frozen_string_literal: true

module SGK
  module Gacha
    # 重み付きガチャエンジン
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
        @cards.last
      end

      # 単一操作で複数のカードを抽選する（例：10連ガチャ）。
      #
      # @param count [Integer] 抽選するカードの枚数
      # @return [Array<Object>] 抽選されたカードの配列
      # @raise [ArgumentError] countが正の値でない場合
      def draw_multiple(count)
        raise ArgumentError, "Draw count must be positive" unless count.positive?

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
