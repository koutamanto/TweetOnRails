puts "Seeding SNS data..."

users_data = [
  { username: "alice", display_name: "Alice", email: "alice@example.com", bio: "Railsエンジニア 🚀 Webを作るのが好き", location: "東京", website: "https://alice.dev" },
  { username: "bob", display_name: "Bob", email: "bob@example.com", bio: "デザイナー 🎨 UIを美しくするのが仕事", location: "大阪" },
  { username: "carol", display_name: "Carol", email: "carol@example.com", bio: "スタートアップ創業者 | Rails/React", location: "福岡" },
  { username: "dave", display_name: "Dave", email: "dave@example.com", bio: "フリーランスエンジニア。Rails/React/Vue", location: "名古屋" },
  { username: "eve", display_name: "Eve", email: "eve@example.com", bio: "学生エンジニア 📚 毎日コーディング", location: "京都" },
]

users = users_data.map do |data|
  User.find_or_initialize_by(email: data[:email]).tap do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.username = data[:username]
    u.display_name = data[:display_name]
    u.bio = data[:bio]
    u.location = data[:location]
    u.website = data[:website] if data[:website]
    u.confirmed_at = Time.current
    u.save!
  end
end

alice, bob, carol, dave, eve = users
puts "Created #{users.count} users"

[[alice, bob], [alice, carol], [bob, alice], [bob, carol],
 [carol, alice], [carol, dave], [dave, alice], [dave, eve],
 [eve, alice], [eve, bob]].each do |(follower, following)|
  Follow.find_or_create_by(follower: follower, following: following)
end
puts "Created follows"

tweets_data = [
  { user: alice, body: "Railsの新機能を試してみた！Turbo Streamsでリアルタイム更新が簡単に実装できて感動。#Rails #Ruby" },
  { user: bob, body: "新しいデザインシステムを構築中。コンポーネントの一貫性って大事だよね 🎨 #Design #UI" },
  { user: carol, body: "スタートアップのプロダクトがついにリリース！たくさんの人に使ってもらえたら嬉しいです 🚀" },
  { user: alice, body: "今日学んだこと：Stimulusコントローラーはシンプルに保つのが重要。複雑なロジックはモデルに分離すべき。" },
  { user: dave, body: "React vs Vue vs Svelte... フロントエンドの選択って難しい。#フロントエンド" },
  { user: eve, body: "プログラミング学習100日目！毎日続けることで確実に成長を感じています 💪 #100DaysOfCode" },
  { user: bob, body: "Tailwind CSS v4が本当に良い。設定ファイルなしでそのまま使えるのが最高 ✨ #TailwindCSS" },
  { user: carol, body: "ユーザーインタビューをしてきました。想定していなかった使い方をしていた！プロダクト開発って奥が深い" },
  { user: alice, body: "おはようございます ☀️ 今日も良いコードを書きましょう！" },
  { user: dave, body: "SQLのインデックスの重要性を改めて実感。N+1問題は早めに対処しないと後で大変 😅" },
]

tweets = tweets_data.map { |d| Tweet.create!(user: d[:user], body: d[:body]) }
puts "Created #{tweets.count} tweets"

[[bob, tweets[0]], [carol, tweets[0]], [dave, tweets[0]],
 [alice, tweets[1]], [carol, tweets[1]],
 [alice, tweets[2]], [bob, tweets[2]], [dave, tweets[2]], [eve, tweets[2]],
 [bob, tweets[3]], [carol, tweets[5]],
 [alice, tweets[6]], [carol, tweets[6]]].each do |(user, tweet)|
  Like.find_or_create_by(user: user, tweet: tweet)
end
puts "Created likes"

Tweet.create!(user: bob, body: "@alice すごい！どんな機能を試しましたか？", parent_tweet_id: tweets[0].id)
Tweet.create!(user: alice, body: "@bob Turbo Streamsと新しいAction Text連携がメインです！", parent_tweet_id: tweets[0].id)

conv = Conversation.create!
conv.participants << alice
conv.participants << bob
Message.create!(conversation: conv, sender: alice, body: "こんにちは！一緒にプロジェクトやりませんか？")
Message.create!(conversation: conv, sender: bob, body: "いいですね！詳しく聞かせてください。")
Message.create!(conversation: conv, sender: alice, body: "Railsアプリを一緒に作ろうと思っています 😊")

puts "✅ Seed complete!"
