# config/initializers/pusher.rb
require 'pusher'

Pusher.app_id = Rails.application.credentials[:PUSHER_APP_ID]
Pusher.key = Rails.application.credentials[:PUSHER_KEY]
Pusher.secret = Rails.application.credentials[:PUSHER_SECRET]
Pusher.cluster = Rails.application.credentials[:PUSHER_CLUSTER]
Pusher.logger = Rails.logger
Pusher.encrypted = true
