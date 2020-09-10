require 'ctoa'
require 'slack-ruby-client'

class CTOA::Slack
  def client
    @client ||= ->() {
      Slack.configure do |config|
        config.token = ENV['SLACK_API_TOKEN']
      end
      Slack::Web::Client.new
    }.call
  end

  def all_members
    @all_members ||= client.users_list.members
  end

  def send_dm_to(member, text)
    client.chat_postMessage(channel: member.id, text: text)
  end
end
