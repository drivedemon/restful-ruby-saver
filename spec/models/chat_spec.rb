require 'rails_helper'

RSpec.describe Chat, type: :model do
  let(:chat) { create :chat }
  before { allow(Pusher).to receive(:trigger) }

  describe '#as_chat_format' do
    subject { chat.as_chat_format }

    it 'uses Chat coordinates' do
      response = subject
      expect(response['latitude']).to eq(chat.latitude)
      expect(response['longitude']).to eq(chat.longitude)
    end

    it 'matches JSON schema' do
      expect(subject).to match_json_schema("chat")
    end
  end

  describe 'is_owner_chat function' do
    let(:opposite_user) { create :user }
    it "should be receive opposite user" do
      expect(chat.user).not_to eq(opposite_user)
    end
  end
end
