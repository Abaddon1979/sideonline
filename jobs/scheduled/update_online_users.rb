# frozen_string_literal: true

module Jobs
  class UpdateOnlineUsers < ::Jobs::Scheduled
    every 1.minute
    
    def execute(args)
      Rails.logger.info("[Sideonline] Job started")
      
      unless SiteSetting.sideonline_enabled
        Rails.logger.warn("[Sideonline] Plugin is disabled in settings")
        return
      end
      
      threshold_minutes = ::Sideonline.active_threshold_minutes
      threshold = threshold_minutes.minutes.ago
      
      Rails.logger.info("[Sideonline] Threshold: #{threshold_minutes} minutes ago (#{threshold})")
      
      # Get total user count first for debugging
      total_users = User.where(active: true).count
      Rails.logger.info("[Sideonline] Total active users in DB: #{total_users}")
      
      # Query for users who have been active recently
      begin
        online_users_records = User
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
        
        Rails.logger.info("[Sideonline] Found #{online_users_records.count} users")
        
        online_users = online_users_records.map do |user|
          {
            id: user.id,
            username: user.username,
            name: user.name,
            avatar_template: user.avatar_template,
            trust_level: user.trust_level,
            admin: user.admin,
            moderator: user.moderator,
            last_seen_at: user.last_seen_at.to_i
          }
        end
        
        # Update the plugin store
        ::Sideonline.update_online_users(online_users)
        
        Rails.logger.info("[Sideonline] Successfully updated: #{online_users.count} users online")
        Rails.logger.info("[Sideonline] Online usernames: #{online_users.map { |u| u[:username] }.join(', ')}")
        
      rescue => e
        Rails.logger.error("[Sideonline] Error updating online users: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end
  end
end
