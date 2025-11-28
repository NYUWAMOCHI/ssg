# frozen_string_literal: true

module SGK
  module Gacha
    # 100回連続でUR（Ultra Rare）カードが出なかった場合、次回の抽選でURカードを保証する

    # 使用例:
    #   engine = SGK::Gacha::Engine.new(GachaCard.all)
    #   pity = SGK::Gacha::PitySystem.new(engine, guarantee_limit: 100, guaranteed_rarity: :ultra_rare)
    #
    #   result = pity.draw(current_pity_count: user_current_pity)
    class PitySystem
      attr_reader :engine, :guarantee_limit, :guaranteed_rarity

      # 初期化
      #
      # @param engine [SGK::Gacha::Engine] 抽選に使用するガチャエンジン
      # @param guarantee_limit [Integer] 保証レアが出るまでの抽選回数（デフォルト: 100）
      # @param guaranteed_rarity [Symbol, String] 保証するレアリティ（デフォルト: :ultra_rare）
      # @raise [ArgumentError] guarantee_limitが正の値でない場合
      def initialize(engine, guarantee_limit: 100, guaranteed_rarity: :ultra_rare)
        raise ArgumentError, "Engine must be a SGK::Gacha::Engine instance" unless engine.is_a?(Engine)
        raise ArgumentError, "Guarantee limit must be positive" unless guarantee_limit.positive?

        @engine = engine
        @guarantee_limit = guarantee_limit
        @guaranteed_rarity = guaranteed_rarity.to_sym
      end

      # カード抽選
      #
      # @param current_pity_count [Integer] 最後の保証カードからの抽選回数
      # @return [Object] 抽選されたカード（pity_count >= guarantee_limitの場合は保証UR）
      # @raise [ArgumentError] current_pity_countが負の値の場合
      def draw(current_pity_count: 0)
        raise ArgumentError, "Pity count must be non-negative" unless current_pity_count >= 0

        # 保証カードを返す
        if current_pity_count >= @guarantee_limit
          return draw_guaranteed_card
        end

        # それ以外の場合は通常の抽選を実行
        @engine.draw
      end

      # 複数のカードを抽選する
      #
      # @param count [Integer] 抽選するカードの枚数
      # @param current_pity_count [Integer] 最後の保証カードからの抽選回数
      # @return [Array<Object>] 保証カードの抽選カードの配列
      # @raise [ArgumentError] countが正の値でない、またはpity_countが負の値の場合
      def draw_multiple(count, current_pity_count: 0)
        raise ArgumentError, "Draw count must be positive" unless count.positive?
        raise ArgumentError, "Pity count must be non-negative" unless current_pity_count >= 0

        results = []
        current_count = current_pity_count

        count.times do
          card = draw(current_pity_count: current_count)
          results << card

          # 保証カードを引いた場合は抽選回数をリセット、それ以外はカウントを増やしていく
          if is_guaranteed_card?(card)
            current_count = 0
          else
            current_count += 1
          end
        end

        results
      end

      # 次の保証までの残り回数と保証回数を取得する
      #
      # @param current_pity_count [Integer] 最後の保証カードからの抽選回数
      # @return [Hash] 次の保証までの残り回数と保証回数
      # @example
      #   pity.next_guarantee_info(current_pity_count: 75)
      #   # => { pity_count: 75, remaining: 25, guaranteed_at: 100 }
      def next_guarantee_info(current_pity_count: 0)
        raise ArgumentError, "Pity count must be non-negative" unless current_pity_count >= 0

        {
          current_pity_count: current_pity_count,
          remaining: [@guarantee_limit - current_pity_count, 0].max,
          guaranteed_at: @guarantee_limit
        }
      end

      private

      # 保証カード（UR）を抽選する
      #
      # @return [Object] 保証されたカード
      # @raise [ArgumentError] 保証カードが利用できない場合
      def draw_guaranteed_card
        guaranteed_cards = @engine.instance_variable_get(:@cards).select do |card|
          card.respond_to?(:rarity) && card.rarity.to_sym == @guaranteed_rarity
        end

        raise ArgumentError, "No cards with rarity #{@guaranteed_rarity} found" if guaranteed_cards.empty?

        # 保証カードからランダムにカードを返す
        guaranteed_cards.sample
      end

      # カードが保証レアリティのカードかどうかをチェックする
      #
      # @param card [Object] 保証レアリティのカードかどうかをチェックするカード
      # @return [Boolean] カードが保証レアリティのカードかどうか
      def is_guaranteed_card?(card)
        card.respond_to?(:rarity) && card.rarity.to_sym == @guaranteed_rarity
      end
    end
  end
end
