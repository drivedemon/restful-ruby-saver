require 'rails_helper'

RSpec.describe HelpRequest, type: :model do
  let(:current_user) { create :user }
  let(:help_request) { create :help_request }
  let(:help_request_at_morphosis) { create :help_request, :at_morphosis }
  let!(:user_disable_green_status) { create :user, notification_status_green: false }
  let!(:user_enable_green_status) { create :user, notification_status_green: true }
  let!(:user_short_range_setting) { create :user, :short_range_setting }

  describe '#as_help_request_format' do
    let(:json) {
      help_request.slice(:id, :description, :price, :color_status_id, :status_id, :distance_scope, :image_help_requests).merge(
        {
          is_owner: false,
          user: help_request.user&.as_profile_json
        }
      )
    }

    it 'general case' do
      subject = help_request.as_help_request_format(current_user)
      expect(subject).to eq(json)
    end

    it "if send the same user check_is_owner should be true" do
      subject = help_request.as_help_request_format(help_request.user)
      expect(subject[:is_owner]).to be_truthy
    end

    it "if send the another user check_is_owner should be false" do
      subject = help_request.as_help_request_format(current_user)
      expect(subject[:is_owner]).to be_falsey
    end

    it "call feed detail" do
      expect(help_request).to receive(:set_request_feed_detail).with(current_user).and_return({test: 1234})
      subject = help_request.as_help_request_format(current_user, true)
      expect(subject).to eq(json.merge({test: 1234}))
    end
  end


  describe 'user distance related notification' do
    it "call push notify in distance with user enable green status" do
      subject = help_request.users_with_same_color_status_within_range
      expect(subject).to include(user_enable_green_status)
    end

    it "call push notify in distance with user disable green status" do
      subject = help_request.users_with_same_color_status_within_range
      expect(subject).not_to include(user_disable_green_status)
    end

    it "call push notify in distance with user out of range" do
      subject = help_request_at_morphosis.users_with_same_color_status_within_range
      expect(subject).not_to include(user_short_range_setting)
    end
  end
end
