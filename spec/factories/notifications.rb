FactoryBot.define do
  factory :notification, class: Notification do
    is_read { false }
    association :user, factory: :user
    association :chat_room, factory: :chat_room
    association :chat, factory: :chat
    association :help_request, factory: :help_request
    association :offer_request, factory: :offer_request
  end
end
