# frozen_string_literal: true

RSpec.describe SGK do
  it "has a version number" do
    expect(SGK::VERSION).not_to be_nil
  end

  describe "modules" do
    it "has Gacha module" do
      expect(defined?(SGK::Gacha)).to be_truthy
    end

    it "has Engine class" do
      expect(defined?(SGK::Gacha::Engine)).to be_truthy
    end

    it "has Result class" do
      expect(defined?(SGK::Gacha::Result)).to be_truthy
    end
  end
end
