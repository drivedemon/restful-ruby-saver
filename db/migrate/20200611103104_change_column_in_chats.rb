class ChangeColumnInChats < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :type, :string, default: "GeneralChat"
    Chat.find_each{ |e|
        case e.chat_type_id
        when 2
          e.update(type: "StartChat")
        when 3
          e.update(type: "AcceptChat")
        when 4
          e.update(type: "ConfirmChat")
        when 5
          e.update(type: "RejectChat")
        when 6
          e.update(type: "StopLocationChat")
        end
    }
    remove_column :chats, :chat_type_id, :bigint
  end
end
