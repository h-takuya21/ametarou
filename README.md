# README
<div align="center">
<img src="https://github.com/h-takuya21/images/blob/master/ametarou.png" alt="ametarou" title="ametarou">
</div>
<h1 align="center">雨太郎(ametarou)</h1>

# 概要
友達登録をすると、大阪府の降水確率を関西弁でお知らせてくれるLINEアカウントです。
LINEID:@270wktqa

# 本番環境
Heroku

# 制作背景
毎日天気予報を調べるのが手間だったので、普段慣れ親しんだLINEでお知らせしてくれると便利だなと思い、制作しました。

# DEMO
<div align="center">
<img src="https://i.gyazo.com/e5d0d3c7caa3a95610d0235a6b55fd7d.gif" alt="ametaroudemo" title="ametaroudemo" width="320px"">
</div
                                                                                                                          
# 工夫したポイント
収集した降水確率をただ送信するだけではなく、雨が降らない場合は降水確率ではなく一言メッセージを送信するなど、
不必要なメッセージは送信しないよう工夫しました。
「こんにちは」など、特定のメッセージには会話をしているかのようなメッセージを返信します。
少しでも愛着が湧くように、関西弁でメッセージを送信します。
。
# 使用技術(開発環境)
Ruby 2.5.1
Rails 5.2.0
PostgreSQL 12.3
LINE Messaging API

# 今後実装したい機能
降水確率ではなく、喘息の発作が出やすい日を予測できるような機能の実装


# DB設計
### usersテーブル
|Column|Type|Options|
|------|----|-------|
|line_id|string|null: false|
|created_at|datetime|null: false|
|updated_at|datetime|null: false|
