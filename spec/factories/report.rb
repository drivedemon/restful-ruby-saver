FactoryBot.define do
  factory :report, class: Report do
    association :help_request, factory: :help_request
    association :offer_request, factory: :offer_request
  end
end
