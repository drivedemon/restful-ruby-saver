class CreateApiChats < ActiveRecord::Migration[6.0]
  def change
    create_table :chats do |t|
      t.text :messsage
      t.text :image
      t.text :location
      t.references :chat_type, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
