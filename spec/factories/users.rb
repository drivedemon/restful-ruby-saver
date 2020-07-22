FactoryBot.define do
  factory :user, class: User do
    sequence(:email) { |n| "test-email-#{n}@mailinator.com" }
    sequence(:first_name) { |n| "Testfirstname#{n}"}
    sequence(:last_name) { |n| "Testlastname#{n}"}
    sequence(:telephone) { |n| "#{n}00000000"}
    sequence(:username) { |n| "testusername-#{n}"}
    sequence(:latitude) { |n| "13.756#{n}" }
    sequence(:longitude) { |n| "100.501#{n}" }
    password { "12341234" }
    password_confirmation { "12341234" }
    notification_status { true }
    association :profession, factory: :profession

    trait :short_range_setting do
      green_distance_scope {1}
      yellow_distance_scope {3}
      red_distance_scope {5}
    end

    trait :with_help_request do
      help_requests { build_list :help_request, 3 }
    end
  end

  factory :profession, class: Profession do
    sequence(:name) { |n| "test-profession-#{n}" }
  end
end
