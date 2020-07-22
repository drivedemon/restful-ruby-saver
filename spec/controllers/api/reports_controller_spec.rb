require 'rails_helper'

RSpec.describe Api::ReportsController, type: :controller do
  describe 'GET index' do
    let(:user) { create :user }
    let(:report_list) {
      [
        {"id" => 1, "type_id" => "It’s suspicious or spam"},
        {"id" => 2, "type_id" => "They’re pretending to be someone else"},
        {"id" => 3, "type_id" => "They’re expressing harmful or hateful content"},
        {"id" => 4, "type_id" => "Others"}
      ]
    }

    subject! { get :index }

    before { login_user(user) }

    it 'get index' do
      expect(response).to have_http_status(200)
    end

    it 'should be correct report list' do
      expect(JSON.parse(response.body)).to eq(report_list)
    end
  end
end
