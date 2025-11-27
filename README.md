# Sideonline Plugin

A lightweight Discourse plugin that tracks online users and exposes them via a JSON API endpoint.

## What it does

- Runs a background job every minute to check for online users
- Stores the list in Discourse's PluginStore
- Exposes online users at `/sideonline.json`
- Respects user privacy settings (hides users who enabled "hide profile and presence")

## Installation

1. Navigate to your Discourse plugins directory:
   ```bash
   cd /var/www/discourse/plugins
   ```

2. Clone or copy this plugin:
   ```bash
   git clone https://github.com/yourusername/sideonline.git
   ```

3. Rebuild Discourse:
   ```bash
   cd /var/www/discourse
   ./launcher rebuild app
   ```

## Settings

Navigate to `Admin > Settings > Plugins` to configure:

- **sideonline_enabled**: Enable/disable the plugin (default: true)
- **sideonline_threshold_minutes**: How many minutes of inactivity before a user is considered offline (default: 5)

## API Endpoint

**GET** `/sideonline.json`

Returns:
```json
{
  "users": [
    {
      "id": 1,
      "username": "admin",
      "name": "Admin User",
      "avatar_template": "/user_avatar/...",
      "trust_level": 4,
      "admin": true,
      "moderator": false,
      "last_seen_at": 1234567890
    }
  ],
  "updated_at": 1234567890
}
```

## Usage with Discord Theme Component

This plugin is designed to work with the Discord-style theme component. The theme component will poll this endpoint to get real-time online user status.

## Privacy

Users who have enabled "Hide profile and presence" in their preferences will NOT appear in the online users list.
