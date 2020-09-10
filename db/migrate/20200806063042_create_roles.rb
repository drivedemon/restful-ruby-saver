class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :alias
      t.timestamps
    end
    add_index :roles, :name, unique: true
    add_index :roles, :alias, unique: true

    add_reference :dashboard_users, :role, index: true
    add_foreign_key :dashboard_users, :roles

    add_column :dashboard_users, :first_name, :string
    add_column :dashboard_users, :last_name, :string

    Role.create name: "Super Admin", alias: "super_admin"
    Role.create name: "Admin", alias: "admin"
    Role.create name: "Sales", alias: "sales"
  end
end
