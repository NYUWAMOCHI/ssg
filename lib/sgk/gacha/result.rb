# frozen_string_literal: true

module SGK
  module Gacha
    # ガチャ抽選の結果を表す。
    #
    class Result
      attr_reader :card

      def initialize(card)
        @card = card
      end

      def name
        @card.name
      end

      def rarity
        @card.rarity
      end

      # JSON変換用メソッド
      def json_format
        {
          card_id: @card.id,
          name: @card.name,
          rarity: @card.rarity
        }
      end
    end
  end
end
