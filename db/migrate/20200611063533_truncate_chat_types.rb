class TruncateChatTypes < ActiveRecord::Migration[6.0]
  def change
    execute("TRUNCATE TABLE chat_types RESTART IDENTITY CASCADE")
  end
end
