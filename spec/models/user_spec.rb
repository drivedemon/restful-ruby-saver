require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create :user }
  let(:other_user) { create :user, :with_help_request }
  let!(:offer_request) { create :offer_request, :with_chat_room, user: user }
  let!(:chat_room) { offer_request.chat_room }
  let!(:my_chat) { create :chat, chat_room: chat_room, user: user }
  let!(:others_chat) { create :chat, chat_room: chat_room, user: other_user }
  let!(:notification) { create :notification, user: user }
  let!(:other_notification) { create :notification, user: other_user }

  describe 'other_user_chats relationship' do
    subject { user.other_user_chats }
    it "should have not receive all chat from my user" do
      expect(subject).not_to include(my_chat)
    end

    it "should have receive all chat except my user " do
      expect(subject).to include(others_chat)
    end
  end

  describe 'read_all! concern validate' do
    subject { user.notifications }
    it "should be receive self notifications" do
      expect(subject).to include(notification)
    end

    it "should have not receive self notifications" do
      expect(subject).not_to include(other_notification)
    end

    it "should have only self notifications with is_read false" do
      expect(subject.where(is_read: false)).not_to include(notification)
    end

    it "should updated notifications is_read false to true" do
      expect do
        subject.read_all!
      end.to change { subject.where(is_read: false).count }.to(0)
    end
  end
end
