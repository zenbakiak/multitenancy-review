class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members, id: :uuid do |t|
      t.references :tenant, index: true, foreign_key: true, type: :uuid
      t.references :user, index: true, foreign_key: true, type: :uuid
      t.integer :status, default: 0

      t.timestamps null: false
    end
  end
end
