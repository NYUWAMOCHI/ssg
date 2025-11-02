# frozen_string_literal: true

RSpec.describe SSG do
  it "has a version number" do
    expect(SSG::VERSION).not_to be_nil
  end

  describe "modules" do
    it "has Gacha module" do
      expect(defined?(SSG::Gacha)).to be_truthy
    end

    it "has Engine class" do
      expect(defined?(SSG::Gacha::Engine)).to be_truthy
    end

    it "has Result class" do
      expect(defined?(SSG::Gacha::Result)).to be_truthy
    end
  end
end
