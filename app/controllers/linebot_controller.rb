class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
        # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        case event.type
          # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          url  = "https://www.drk7.jp/weather/xml/27.xml"
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = 'weatherforecast/pref/area[1]/'
          # 当日朝のメッセージの送信の下限値は20％としているが、明日・明後日雨が降るかどうかの下限値は30％としている
          min_per = 30
          case input
            # 「明日」or「あした」というワードが含まれる場合
          when /.*(明日|あした).*/
            # info[2]：明日の天気
            per06to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明日の天気やんな。\n明日は雨が降りそうやで(>_<)\n今のとこ降水確率はこんな感じ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            else
              push =
                "明日の天気？\n明日は雨が降らん予定やで(^^)\nまた明日の朝に雨が降りそうやったら教えるわ！"
            end
          when /.*(明後日|あさって).*/
            per06to12 = doc.elements[xpath + 'info[3]/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info[3]/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info[3]/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明後日の天気やんな。\n何か用事あるん？\n明後日は雨が降りそうや…\nまた当日の朝に雨が降りそうやったら教えるわ！"
            else
              push =
                "明後日の天気か？\n気ぃ早いなー！何かあるん？\n明後日は雨は降らん予定やで(^^)\nまた当日の朝に雨が降りそうやったら教えるわ！"
            end
          when /.*(かわいい|可愛い|カワイイ|きれい|綺麗|キレイ|かっこいい|格好いい|イケメン|素敵|ステキ|すてき|面白い|おもしろい|ありがと|すごい|スゴイ|スゴい|好き|頑張|がんば|ガンバ).*/
            push =
              "おおきに！！！\nめっちゃ優しいな！お世辞でも嬉しいで(^^)"
          when /.*(こんにちは|こんばんは|初めまして|はじめまして|おはよう).*/
            push =
              "まいど！\n声かけてくれてありがとう！\n今日があんたにとっていい日になりますように(^^)"
          when /.*(さようなら|バイバイ|ばいばい|寝る|おやすみ).*/
            push =
              "今日もようやったな！\n明日もあんたにとっていい日になるで(^^)"
          when /.*(眠|夜更かし|寝てない|うとうと|しんどい).*/
            push =
              "起きや！\n眠気に負けたらあかんで！"
          when /.*(山|ハイキング|ピクニック|散歩|ジョギング|ウォーキング|出かけ|出掛け).*/
            push =
              "ちゃんと天気確認したか！？\n行ってらっしゃい！"
            when /.*(コロナ|ウィルス|COVID|covid|感染症).*/
              push =
                "できる対策はきちんとやろうな！\n手洗い・うがい、忘れたらあかんで！\n3密は避けるように！！"
          else
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word =
                ["雨やけど元気出していこや！",
                 "雨に負けたらあかんで！！",
                 "雨やけどあんたの明るさでみんなを元気にしてや(^^)"].sample
              push =
                "今日の天気か？\n今日は雨が降りそうやから傘があった方が安心やで。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word}"
            else
              word =
                ["天気もええから一駅歩いてみたらどうや？(^^)",
                 "今日会う人のええところを見つけて是非その人に教えたって(^^)",
                 "ええ一日になりますように(^^)",
                 "雨が降ったらごめんやで(><)"].sample
              push =
                "今日の天気？\n今日は雨は降らんと思うで。\n#{word}"
            end
          end
          # テキスト以外（画像等）のメッセージが送られた場合
        else
          push = "テキスト以外はわからんな〜(；；)"
        end
        message = {
          type: 'text',
          text: push
        }
        client.reply_message(event['replyToken'], message)
        # LINEお友達追された場合（機能②）
      when Line::Bot::Event::Follow
        # 登録したユーザーのidをユーザーテーブルに格納
        line_id = event['source']['userId']
        User.create(line_id: line_id)
        # LINEお友達解除された場合（機能③）
      when Line::Bot::Event::Unfollow
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end