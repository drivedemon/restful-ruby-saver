class DropChatTypes < ActiveRecord::Migration[6.0]
  def change
    drop_table :chat_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
