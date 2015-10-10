class CreatePics < ActiveRecord::Migration
  def change
    create_table :pics do |t|
      t.string :name
      t.string :ipfs_hash

      t.timestamps null: false
    end
  end
end
