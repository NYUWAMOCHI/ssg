# SSG

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ssg`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

### 基本的な使用方法

```ruby
# カードデータの準備
cards = [
  GachaCard.new(id: 1, name: "コモン", rarity: "common", weight: 70),
  GachaCard.new(id: 2, name: "レア", rarity: "rare", weight: 25),
  GachaCard.new(id: 3, name: "SR", rarity: "super_rare", weight: 4),
  GachaCard.new(id: 4, name: "UR", rarity: "ultra_rare", weight: 1)
]

# エンジンの初期化
engine = SSG::Gacha::Engine.new(cards)

# 単発抽選
result = engine.draw
puts result.name # => "コモン" など

# 複数回抽選
results = engine.draw_multiple(10)
puts results.size # => 10

# 確率の計算
probabilities = engine.probabilities
# => {1=>70.0, 2=>25.0, 3=>4.0, 4=>1.0}
```

### 確率計算のメモリ効率について

`probabilities` メソッドは、実際に存在するカードのIDだけをハッシュに保存します。IDが飛び飛び（例: 1-100と1000-10000）の場合でも、間のIDのエントリは作成されません。

**重要**: Rubyのハッシュは疎なデータ構造のため、存在しないキーは保存されません。メモリ消費は実際に存在するカード数に比例します。

#### ⚠️ 配列を使った場合の問題（Railsでの実例）

Rubyの配列では、未使用インデックスを指定して値を代入すると、インデックスまでの間のヒープが確保されてしまいます：

```ruby
arr = []
arr[3] = 1
puts arr.inspect # => [nil, nil, nil, 1]
# インデックス0-2のnilもメモリに確保される
```

**ガチャでの実際の問題事例**:
ガチャIDを配列のインデックスとして使用していた場合、IDが1-100と1000-10000のカードがあると、ID 101-999の間も`nil`としてメモリに確保されてしまい、巨大なヒープが作成されメモリを大量に消費していました。

```ruby
# ❌ 配列を使った悪い例（メモリを大量に消費）
def probabilities
  result = []
  @cards.each do |card|
    result[card.id] = (card.weight.to_f / @total_weight * 100).round(2)
    # ID 1と10000のカードがあると、インデックス1-10000までの巨大な配列が作成される
    # （間のインデックスもnilとしてメモリに確保される）
  end
  result
end
```

**解決策**: 連想配列（ハッシュ）を使用することで、存在しないIDのメモリ確保を回避できます。



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ssg.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
