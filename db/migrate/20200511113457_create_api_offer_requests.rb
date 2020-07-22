class CreateApiOfferRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :offer_requests do |t|
      t.text :description
      t.string :chat_room_id
      t.integer :helper_status
      t.integer :helpee_status
      t.references :help_request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
