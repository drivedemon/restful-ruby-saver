class CreateChatRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_rooms do |t|
      t.references :help_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
