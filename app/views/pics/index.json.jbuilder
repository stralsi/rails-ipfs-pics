json.array!(@pics) do |pic|
  json.extract! pic, :id, :name, :ipfs_hash
  json.url pic_url(pic, format: :json)
end
