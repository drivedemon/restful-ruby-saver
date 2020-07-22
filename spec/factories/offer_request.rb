FactoryBot.define do
  factory :offer_request, class: OfferRequest do
    association :user, factory: :user
    association :help_request, factory: :help_request
    association :helpee_request_status, factory: :helpee_request_status
    association :helper_request_status, factory: :helper_request_status

    sequence(:latitude) { |n| "13.756#{n}" }
    sequence(:longitude) { |n| "100.501#{n}" }
    sequence(:description) { |n| "test-description-#{n}" }

    trait :with_chat_room do
      association :chat_room, factory: :chat_room
    end

    trait :with_complete_status do
      helpee_request_status_id { 3 }
      helper_request_status_id { 3 }
    end
  end
end
