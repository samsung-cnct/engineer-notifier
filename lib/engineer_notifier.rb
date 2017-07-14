require 'slack-ruby-bot'
require 'json'

module SlackBot
  class EngineerNotifier < SlackRubyBot::Bot

    MENTIONS_TO_HANDLES = JSON.parse ENV['MENTIONS_TO_HANDLES']
    CHANNEL_IDS = JSON.parse ENV['CHANNEL_IDS']

    match /.*/ do |client, data, match|
      if valid_channel?(data.channel)
        data[:attachments].try(:each) do |attachment|
          next unless attachment.text

          MENTIONS_TO_HANDLES.each do |mention, handle|
            if attachment.text.split(' ').include?(mention)
              post_notification(data: data, handle: handle, client: client)
            end
          end
        end
      end
    end

    private

    def self.post_notification(data:, handle:, client:)
      client.say(channel: data.channel, text: "<#{handle}> You have been mentioned in a Github PR comment. Please check above.")
    end

    def self.valid_channel?(channel_id)
      CHANNEL_IDS.include?(channel_id)
    end

  end
end
