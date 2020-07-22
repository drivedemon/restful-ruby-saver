require 'rails_helper'

RSpec.describe Api::User::ConversationsController, type: :controller do
  describe 'GET index' do
    let(:user) { create :user, green_distance_scope: 5 }
    let(:params) do
      {
        current_latitude: "13.7270568",
        current_longitude: "100.5306758"
      }
    end

    let!(:help_request) { create :help_request, user: user }
    let!(:help_request_without_user) { create :help_request }
    let!(:offer_request) { create :offer_request, :with_chat_room, help_request: help_request }
    let!(:offer_request_completed) { create :offer_request, :with_chat_room, :with_complete_status, help_request: help_request }
    let!(:offer_request_without_chat_room) { create :offer_request, help_request: help_request }
    let!(:offer_request_without_help_request) { create :offer_request, help_request: help_request_without_user }

    subject { get :index, params: params }

    before { login_user(user) }

    it 'get index' do
      expect(subject).to have_http_status(200)
    end

    it 'should have offer request that have chat_room' do
      subject
      expect(assigns(:offer_requests_related_to_help_requests)).to include(offer_request.as_offer_request_format(user))
    end

    it 'should not have offer request that does not have chat_room' do
      subject
      expect(assigns(:offer_requests_related_to_help_requests)).not_to include(offer_request_without_chat_room.as_offer_request_format(user))
    end

    it 'should not have offer request that does not belong to user' do
      subject
      expect(assigns(:offer_requests_related_to_help_requests)).not_to include(offer_request_without_help_request.as_offer_request_format(user))
    end

    it 'should have offer request that have chat_room except completed helper status' do
      subject
      expect(assigns(:offer_requests_related_to_help_requests)).not_to include(offer_request_completed.as_offer_request_format(user))
    end
  end
end
