# frozen_string_literal: true
# name: sideonline
# about: Tracks online users and exposes them via JSON endpoint for the Discord style theme
# version: 1.0.0
# authors: Discord Theme Team
# url: https://github.com/yourusername/sideonline

enabled_site_setting :sideonline_enabled

after_initialize do
  
  module ::Sideonline
    PLUGIN_NAME = "sideonline"
    
    class << self
      def online_users
        PluginStore.get(PLUGIN_NAME, "online_users") || []
      end
      
      def update_online_users(users)
        PluginStore.set(PLUGIN_NAME, "online_users", users)
      end
      
      def active_threshold_minutes
        SiteSetting.sideonline_threshold_minutes || 5
      end
    end
  end
  
  # API Controller to serve online users as JSON
  class ::Sideonline::OnlineUsersController < ::ApplicationController
    requires_plugin ::Sideonline::PLUGIN_NAME
    skip_before_action :verify_authenticity_token
    
    def index
      render json: { 
        users: ::Sideonline.online_users,
        updated_at: Time.now.to_i
      }
    end
  end
  
  # Register route
  Discourse::Application.routes.append do
    get "/sideonline.json" => "sideonline/online_users#index"
  end
  
  # Load scheduled job
  load File.expand_path("../jobs/scheduled/update_online_users.rb", __FILE__)
end
