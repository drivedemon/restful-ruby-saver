require 'rails_helper'

RSpec.describe Api::HelpRequestsController, type: :controller do
  describe 'GET index' do
    let(:user) { create :user, green_distance_scope: 5 }
    let(:params) do
      {
        current_latitude: "13.7270568",
        current_longitude: "100.5306758"
      }
    end

    let!(:help_request_at_morphosis) { create(:help_request, :at_morphosis) }
    let!(:urgent_help_request) { create(:help_request, :urgent_status) }

    subject { get :index, params: params }

    before { login_user(user) }

    it 'get index' do
      expect(subject).to have_http_status(200)
    end

    it "should return correct help_request within latitude longitude" do
      subject
      expect(assigns(:help_requests)).to include(help_request_at_morphosis)
    end

    it "should be red" do
      expect(urgent_help_request.color_status).to eq("red")
    end
  end
end
