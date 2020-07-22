require 'rails_helper'

RSpec.describe Api::ChatRoomsController, type: :controller do
  let(:user) { create :user }

  before { login_user(user) }

  describe 'POST create' do
    let(:help_request) { create :help_request }
    let(:offer_request) { create :offer_request, help_request: help_request }

    subject { ChatRoom.new(help_request: help_request, offer_request: offer_request) }


    it "should be create chat room" do
      expect do
        subject.save
      end.to change { ChatRoom.count }.by(1)
    end
  end

  describe 'GET show' do
    let!(:helper_user) { create :user }
    let!(:chat_room) { create :chat_room }
    let!(:chat) { create :chat, is_read: false, chat_room: chat_room }
    let!(:chat_requester) { create :chat, is_read: false, chat_room: chat_room, user: user }

    subject { get :show, params: { id: chat_room.id } }

    before { subject }

    it "should be get chat list and is_read status false " do
      expect(assigns(:chats)).to include(chat)
    end

    it "helper get chat should be update chat list" do
      expect(chat_requester.user).not_to eq(helper_user)
      chat_requester.update(is_read: true)
      expect(chat_requester).to be_truthy
    end
  end
end
