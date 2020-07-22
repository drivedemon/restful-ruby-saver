class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.string :order_id
      t.references :help_request, null: false, foreign_key: true
      t.integer :amount
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_column :help_requests, :is_paid, :boolean, default: false
  end
end
