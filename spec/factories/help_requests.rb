FactoryBot.define do
  factory :help_request, class: HelpRequest do
    association :user, factory: :user

    sequence(:latitude) { |n| "13.756#{n}" }
    sequence(:longitude) { |n| "100.501#{n}" }
    sequence(:description) { |n| "test-description-#{n}" }
    price { 10_000 }
    distance_scope {5}
    status {1}
    color_status {1}

    trait :at_morphosis do
      sequence(:latitude) { |n| "13.7270568#{n}" }
      sequence(:longitude) { |n| "100.5306758#{n}" }
    end

    trait :urgent_status do
      color_status {3}
    end
  end
end
