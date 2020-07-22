require 'rails_helper'

RSpec.describe OfferRequest, type: :model do
  let(:current_user) { create :user }
  let(:offer_request) { create :offer_request }

  describe '#define_topic_notification' do

    it 'create offer request should be receive notification OFFER_REQUEST_TOPIC format' do
      subject = offer_request.define_topic_notification(nil, nil)
      expect(subject).to include(OfferRequest::OFFER_REQUEST_TOPIC)
    end

    it 'create offer request should be receive notification CANCEL_ACCEPT_HELPEE_TOPIC format' do
      subject = offer_request.define_topic_notification(nil, [nil, 4])
      expect(subject).to include(OfferRequest::CANCEL_ACCEPT_HELPEE_TOPIC)
    end
  end
end
