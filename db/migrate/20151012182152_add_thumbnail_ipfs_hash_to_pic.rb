class AddThumbnailIpfsHashToPic < ActiveRecord::Migration
  def change
    add_column :pics, :thumbnail_ipfs_hash, :string
  end
end
