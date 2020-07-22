class AddReferenceOfferRequestIdToChatRooms < ActiveRecord::Migration[6.0]
  def change
    remove_column :offer_requests, :chat_room_id
    add_reference :chat_rooms, :offer_request, :null => true, foreign_key: true
  end
end
