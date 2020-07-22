require 'rails_helper'

RSpec.describe Rate, type: :model do
  let(:user) { create :user }
  let(:offer_request) { create :offer_request }
  subject { Rate.new(user: user, offer_request: offer_request) }

  describe 'create' do
    it "should be create successfully" do
      allow_any_instance_of(HelpRequest).to receive(:push_notify_in_distance)
      allow_any_instance_of(Rate).to receive(:push_notify_to_user)
      expect(subject.save).to be_truthy
    end
  end

  describe 'create_notify_history' do
    before do
      allow_any_instance_of(HelpRequest).to receive(:push_notify_in_distance)
      allow_any_instance_of(Rate).to receive(:push_notify_to_user)
    end

    it "should be create notification" do
      expect do
        subject.save
      end.to change { subject.notifications.count }.by(1)
    end

    it "should be correct user id" do
      subject.save
      notification = subject.notifications.last
      expect(notification.user_id).to eq(offer_request.user_id)
    end
  end

  describe 'push notify to user' do
    before do
      allow(Pusher).to receive(:trigger)
      allow(FcmNotification).to receive(:source_data_notification)
      allow_any_instance_of(HelpRequest).to receive(:push_notify_in_distance)
    end

    it 'should be receive push_notification' do
      expect(subject.offer_request.user).to receive(:notification_status).and_return(true).at_least(1)

      expect(FcmNotification).to receive(:push_notification).with(
        "You are the best!", anything, anything, subject.offer_request.user, subject.offer_request.as_offer_request_format
      )
      subject.push_notify_to_user
    end

    it 'should not receive push_notification' do
      expect(subject.offer_request.user).to receive(:notification_status).and_return false

      expect(FcmNotification).not_to receive(:push_notification)
      subject.push_notify_to_user
    end
  end
end
