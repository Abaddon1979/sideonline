# frozen_string_literal: true

module Jobs
  class UpdateOnlineUsers < ::Jobs::Scheduled
    every 1.minute
    
    def execute(args)
      return unless SiteSetting.sideonline_enabled
      
      threshold = ::Sideonline.active_threshold_minutes.minutes.ago
      
      # Query for users who have been active recently
      online_users = User
        .where("last_seen_at > ?", threshold)
        .where(silenced_till: nil)
        .where(suspended_till: nil)
        .where.not(staged: true)
        .where("NOT EXISTS (
          SELECT 1 FROM user_options uo 
          WHERE uo.user_id = users.id 
          AND uo.hide_profile_and_presence = true
        )")
        .limit(200)
        .pluck(:id, :username, :name, :avatar_template, :trust_level, :admin, :moderator, :last_seen_at)
        .map do |id, username, name, avatar_template, trust_level, admin, moderator, last_seen_at|
          {
            id: id,
            username: username,
            name: name,
            avatar_template: avatar_template,
            trust_level: trust_level,
            admin: admin,
            moderator: moderator,
            last_seen_at: last_seen_at.to_i
          }
        end
      
      # Update the plugin store
      ::Sideonline.update_online_users(online_users)
      
      Rails.logger.info("[Sideonline] Updated online users: #{online_users.count} users")
    end
  end
end
