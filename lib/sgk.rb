# frozen_string_literal: true

require_relative "sgk/version"
require_relative "sgk/gacha/engine"
require_relative "sgk/gacha/result"
require_relative "sgk/gacha/pity_system"
require_relative "sgk/gacha/multiple_draw"

module SGK
  class Error < StandardError; end
end
