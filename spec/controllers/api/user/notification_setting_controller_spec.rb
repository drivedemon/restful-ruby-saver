require "rails_helper"

RSpec.describe Api::User::NotificationSettingController, type: :controller do
  describe "PATCH clear all notification" do
    let(:user) { create :user }
    let!(:chat) { create :chat, user: user }
    let(:chat_unread) { create :chat, is_read: false, user: user }
    let!(:notification) { create :notification, user: user }
    let(:notification_unread) { create :notification, user: user }

    subject { patch :clear }

    before { login_user(user) }

    it "should be updated successfully" do
      expect(subject).to have_http_status(200)
    end

    it "should have not chat or notification is_read status false after updated" do
      expect(user.chats).to include(chat)
      expect do
        subject
      end.to change { chat.reload.is_read }.from(false).to(true)
      expect(user.chats.last).not_to eq(chat_unread)
    end
  end
end
