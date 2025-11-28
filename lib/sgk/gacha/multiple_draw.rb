# frozen_string_literal: true

module SGK
  module Gacha
    # 10連ガチャ
    #
    # 使用例:
    #   engine = SGK::Gacha::Engine.new(GachaCard.all)
    #   drawer = SGK::Gacha::MultipleDraw.new(engine, draw_count: 10)
    #   results = drawer.execute
    class MultipleDraw
      DEFAULT_DRAW_COUNT = 10

      attr_reader :engine, :draw_count

      # 初期化
      #
      # @param engine [SGK::Gacha::Engine] 使用するガチャエンジン
      # @param draw_count [Integer] 抽選するカードの枚数（デフォルト: 10）
      # @raise [ArgumentError] engineが無効、またはdraw_countが正の値でない場合
      def initialize(engine, draw_count: DEFAULT_DRAW_COUNT)
        raise ArgumentError, "Engine must be a SGK::Gacha::Engine instance" unless engine.is_a?(Engine)
        raise ArgumentError, "Draw count must be positive" unless draw_count.positive?

        @engine = engine
        @draw_count = draw_count
      end

      # 複数抽選を実行する
      #
      # @return [Array<Object>] 抽選されたカードの配列
      def execute
        @engine.draw_multiple(@draw_count)
      end

      # executeのエイリアス
      alias draw execute
    end
  end
end
