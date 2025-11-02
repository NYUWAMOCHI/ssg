# frozen_string_literal: true

module SSG
  module Gacha
    # Represents the result of a gacha draw.
    #
    # This class wraps a card object and provides convenient accessors
    # for common card properties. It can be serialized to a hash for
    # logging or API responses.
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

      # Convert the result to a hash for JSON serialization.
      #
      # @return [Hash] A hash containing card_id, name, and rarity
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
