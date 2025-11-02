# SSG (Social game Support Gem)

Ruby on Railsアプリケーション向けのソーシャルゲーム機能を提供するgemです。
重み付き確率に基づくガチャ機能を実装しており、メモリ効率を考慮した設計になっています。

## 機能

- 重み付きガチャ機能
- 確率計算機能
- 単発・複数回ガチャ対応（10連ガチャ等）

## インストール

Gemfileに以下を追加：

```ruby
gem 'ssg'
```

その後、以下を実行：

```bash
bundle install
```

## 要件

- Ruby 3.1.0以上
- Rails 6.0以上
- ActiveRecord
- ActiveSupport

## 使用方法

### 基本的な使用方法

```ruby
require 'ssg'

# カードマスタデータ（ActiveRecordモデル）から抽選
cards = GachaCard.all

# エンジンの初期化
engine = SSG::Gacha::Engine.new(cards)

# 単発抽選
card = engine.draw
puts card.name    # => "コモン" など
puts card.rarity  # => "common"

# 複数回抽選（10連ガチャ）
results = engine.draw_multiple(10)
puts results.size # => 10

# 確率の計算
probabilities = engine.probabilities
# => {1=>70.0, 2=>25.0, 3=>4.0, 4=>1.0}
```

### Railsアプリケーションでの例

```ruby
# app/models/gacha_card.rb
class GachaCard < ApplicationRecord
  validates :name, :rarity, :weight, presence: true
  validates :weight, numericality: { greater_than: 0 }

  enum rarity: {
    common: 0,
    rare: 1,
    super_rare: 2,
    ultra_rare: 3
  }
end

# app/controllers/gacha_controller.rb
class GachaController < ApplicationController
  def draw
    engine = SSG::Gacha::Engine.new(GachaCard.all)
    @result = engine.draw

    # ユーザーにカードを付与する処理など
    current_user.gacha_cards << @result

    render json: @result.json_format
  end

  def draw_multiple
    count = params[:count].to_i.clamp(1, 10)  # 最大10連
    engine = SSG::Gacha::Engine.new(GachaCard.all)
    @results = engine.draw_multiple(count)

    current_user.gacha_cards.push(*@results)

    render json: {
      cards: @results.map(&:json_format)
    }
  end

  def probabilities
    engine = SSG::Gacha::Engine.new(GachaCard.all)

    render json: engine.probabilities
  end
end
```

### ガチャカードモデルの例

```ruby
# db/migrate/20240101000000_create_gacha_cards.rb
class CreateGachaCards < ActiveRecord::Migration[7.0]
  def change
    create_table :gacha_cards do |t|
      t.string :name, null: false
      t.string :rarity, null: false
      t.integer :weight, null: false, default: 1
      t.text :description
      t.string :image_url

      t.timestamps
    end

    add_index :gacha_cards, :rarity
    add_index :gacha_cards, :weight
  end
end

# db/seeds.rb
GachaCard.create!([
  { name: "コモンカード", rarity: :common, weight: 70 },
  { name: "レアカード", rarity: :rare, weight: 25 },
  { name: "スーパーレアカード", rarity: :super_rare, weight: 4 },
  { name: "ウルトラレアカード", rarity: :ultra_rare, weight: 1 }
])
```

## 重み付き抽選アルゴリズム

このgemは累積重み方式を使用して、効率的にカードを抽選します。

### アルゴリズムの説明

1. 全カードの重みを合計（total_weight）
2. 0〜total_weightの範囲でランダム値を生成
3. 累積重みを計算しながら、ランダム値が該当する範囲のカードを選択

### 例

```
カードA: 重み70 (累積: 0-69)
カードB: 重み25 (累積: 70-94)
カードC: 重み4  (累積: 95-98)
カードD: 重み1  (累積: 99)
合計: 100

ランダム値75 → カードBを選択
```

## APIリファレンス

### SSG::Gacha::Engine

#### `initialize(card_relation)`

ActiveRecord::Relationを受け取ります。

```ruby
engine = SSG::Gacha::Engine.new(GachaCard.all)
```

#### `draw`

単発ガチャを実行し、カードを返します。

```ruby
card = engine.draw
```

#### `draw_multiple(count)`

複数回ガチャを実行します。countは正の整数である必要があります。

```ruby
cards = engine.draw_multiple(10)  # 10連ガチャ
```

#### `probabilities`

各カードの確率（パーセント）をハッシュで返します。

```ruby
probs = engine.probabilities
# => {1=>70.0, 2=>25.0, 3=>4.0, 4=>1.0}
```

### SSG::Gacha::Result

ガチャ結果をラップするクラスです。

#### `card`

抽選されたカードオブジェクトを返します（読み取り専用）。

#### `name`

カード名を返します。

#### `rarity`

カードのレア度を返します。

#### `json_format`

カード情報をハッシュで返します（JSON化用）。

```ruby
result = engine.draw
result.json_format
# => { card_id: 1, name: "コモン", rarity: "common" }
```

## メモリ効率について

このgemの`probabilities`メソッドはハッシュを使用しており、実際に存在するカードのIDだけを保存します。
IDが飛び飛びの場合（例: 1-100と1000-10000）でも、間のIDのエントリは作成されません。

⚠️ **配列を使った場合の問題**

```ruby
# ❌ 配列を使った実装（メモリを大量に消費）
arr = []
arr[1000] = "value"
# インデックス0-999もメモリに確保される
```

このgemはハッシュを使用することでこの問題を回避しています。

## 開発

リポジトリをクローンした後：

```bash
bundle install
```

テストを実行：

```bash
bundle exec rspec
```

コード品質をチェック：

```bash
bundle exec rubocop
```

対話的なプロンプトで実験：

```bash
bin/console
```

gemをローカルにインストール：

```bash
bundle exec rake install
```

## テスト

このgemは包括的なテストスイートを含みます。

```bash
# 全テスト実行
bundle exec rake

# RSpecのみ実行
bundle exec rspec

# RuboCopのみ実行
bundle exec rubocop
```

## 貢献

バグレポートやプルリクエストはGitHubで歓迎します。

https://github.com/NYUWAMOCHI/ssg

## ライセンス

このgemは[MIT License](https://opensource.org/licenses/MIT)の下でオープンソースとして利用可能です。

詳細は[LICENSE.txt](LICENSE.txt)を参照してください。
