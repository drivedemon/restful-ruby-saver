class AddProfessionIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :profession, :null => true, foreign_key: true
  end
end
