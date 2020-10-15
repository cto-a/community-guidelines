require 'ctoa'
require 'thor'

class CTOA::Slack::CLI < Thor
  desc 'check_member_profiles_if_they_comply_slack_guidelines', 'Slack利用ガイドラインに基づくプロフィール設定がされているかどうかをチェックし、されていない場合にDMでうながす'
  def check_member_profiles_if_they_comply_slack_guidelines
    not_compliant_members = 0
    template = <<~'EOS'
      <%= member.profile.real_name %>さん、こんにちは！このSlackコミュニティの世話をしている、日本CTO協会理事のあんちぽです！！１

      現在設定されているプロフィールの状態が、Slack利用ガイドラインに準拠していない可能性があるため、改善を提案するべくDMしています！

      CTO協会のSlackコミュニティも数百人規模となりました。コミュニティメンバーの発言の心理的安全性を確保するためにも、みなさんに「Slack利用ガイドライン」に定められているプロフィールの設定をお願いしております。

      Slack利用ガイドラインをあらためてご確認いただき、プロフィールの設定をお願いいたします〜〜〜 :pray:

      ----

      *Slack利用ガイドライン*
      https://github.com/cto-a/community-management-resources/blob/master/slack-guidelines.md#%E3%83%97%E3%83%AD%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AB%E3%81%AE%E8%A8%AD%E5%AE%9A%E3%82%92%E3%81%97%E3%81%BE%E3%81%97%E3%82%87%E3%81%86

      ----

      それでは、Happy Slacking！！１
    EOS

    slack.all_members.each do |member|
      if profile_violates_guidelines?(member.profile)
        not_compliant_members += 1
        slack.send_dm_to(member, CTOA::Util.render_text(template, binding))
        puts "DM sent to #{member.profile.real_name}."
        sleep 1
      end
    end

    puts <<~EOS
     メンバー総数: #{slack.all_members.length}（準拠: #{slack.all_members.length - not_compliant_members}、非準拠: #{not_compliant_members}）

     非準拠の#{slack.all_members.length - not_compliant_members}の方に、以下の内容でDMを送りました。

     #{template}
     EOS
  end

  desc 'num_of_members_whose_profiles_dont_comply_slack_guidelines', 'Slack利用ガイドラインに基づくプロフィール設定がされていない人数を表示する'
  def num_of_members_whose_profiles_dont_comply_slack_guidelines
    not_compliant_members = slack.all_members.count do |m|
      profile_violates_guidelines?(m.profile)
    end

    puts "メンバー総数: #{slack.all_members.length}（準拠: #{slack.all_members.length - not_compliant_members}、非準拠: #{not_compliant_members}）"
  end

  desc 'dump-member-ids', 'メンバー全員のIDをカンマ区切りで表示する'
  def dump_member_ids
    puts(slack.all_members.map(&:id).join(','))
  end

  private

  def slack
    @slack ||= CTOA::Slack.new
  end

  # Slack利用ガイドライン
  # https://github.com/cto-a/community-management-resources/blob/master/slack-guidelines.md
  def profile_violates_guidelines?(profile)
    profile.title.empty? ||     # 役職・担当
    profile.display_name.empty? # 準拠してたら空にはならない
  end
end
