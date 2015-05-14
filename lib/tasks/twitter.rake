task(:twitter_load => :environment) do
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['twitter_consumer_key']
    config.consumer_secret     = ENV['twitter_consumer_secret']
    config.access_token        = ENV['twitter_access_token']
    config.access_token_secret = ENV['twitter_access_token_secret']
  end

  TweetStream.configure do |config|
    config.consumer_key        = ENV['twitter_consumer_key']
    config.consumer_secret     = ENV['twitter_consumer_secret']
    config.oauth_token         = ENV['twitter_access_token']
    config.oauth_token_secret  = ENV['twitter_access_token_secret']
    config.auth_method = :oauth
  end

  TweetStream::Client.new.track('rubotweet') do |status|
    status_pre = status.text
    puts status_pre
    filtered_status = status_pre.gsub(/@?rubotweet/, '').strip
    response =  HTTParty.post('http://eval.so/api/evaluate',
      body: {
        language: "ruby",
        code: filtered_status
      }.to_json,
      headers: { 'Content-Type' => 'application/json' })
    eval_status = response['stdout'].strip
    if response['stderr'].empty?
      client.update("@#{status.user.screen_name} #{eval_status}", in_reply_to_status_id: status.id)
    end
  end
end
