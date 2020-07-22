require "rails_helper"

RSpec.describe Api::User::HistoriesController, type: :controller do
  describe "GET index" do
    let(:user_a) { create :user }
    let(:user_b) { create :user }
    let!(:help_request) { create :help_request, status: 3, user: user_a }
    let!(:help_request_completed) { create :help_request, status: 3, user: user_a }
    let!(:help_request_rejected) { create :help_request, status: 2, user: user_a }
    let!(:offer_request_a) { create :offer_request, user: user_a }
    let!(:offer_request_b) { create :offer_request, user: user_b }

    subject { get :index }

    before { login_user(user_a) }

    it "get index" do
      expect(subject).to have_http_status(200)
    end

    it "should be have help request with belong to user" do
      subject
      expect(assigns(:help_requests)).to include(help_request.as_help_request_format(user_a, true))
    end

    it "should be return help request only completed and rejected status" do
      help_request_rejected.destroy
      subject
      expect(assigns(:help_requests)).to include(help_request_completed.as_help_request_format(user_a, true))
      expect(assigns(:help_requests)).to include(help_request_rejected.as_help_request_format(user_a, true))
    end

    it "should not have help request that does not belong to user" do
      subject
      expect(assigns(:help_requests)).not_to include(help_request.as_help_request_format(user_b, true))
    end

    it "should be have offer request with belong to user" do
      subject
      expect(assigns(:offer_requests)).to include(offer_request_a.as_offer_request_format(user_a, true))
    end

    it "should not have offer request that does not belong to user" do
      subject
      expect(assigns(:offer_requests)).not_to include(offer_request_b.as_offer_request_format(user_b, true))
    end
  end
end
