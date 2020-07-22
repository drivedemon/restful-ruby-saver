FactoryBot.define do
  factory :chat, class: Chat do
    sequence(:message) { |n| "test-message-#{n}" }
    association :user, factory: :user
    association :chat_room, factory: :chat_room

    sequence(:latitude) { |n| "13.756#{n}" }
    sequence(:longitude) { |n| "100.501#{n}" }
  end

  factory :chat_room, class: ChatRoom do
    association :help_request, factory: :help_request
    association :offer_request, factory: :offer_request
  end
end
