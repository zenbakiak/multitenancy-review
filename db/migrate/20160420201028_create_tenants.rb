class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :name
      t.string :subdomain
      t.integer :status

      t.timestamps null: false
    end
  end
end
