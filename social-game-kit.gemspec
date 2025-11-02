# frozen_string_literal: true

require_relative "lib/sgk/version"

Gem::Specification.new do |spec|
  spec.name = "social-game-kit"
  spec.version = SGK::VERSION
  spec.authors = ["sugawara_nagisa"]
  spec.email = ["nyuwamochi@gmail.com"]

  spec.summary = "Social Game Kit for Ruby on Rails"
  spec.description = "Rails向けソーシャルゲーム機能kit。重み付きガチャエンジンなど"
  spec.homepage = "https://github.com/NYUWAMOCHI/social-game-kit"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # 必須依存
  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"
end
