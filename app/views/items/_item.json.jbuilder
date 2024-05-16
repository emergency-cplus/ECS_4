json.extract! item, :id, :title, :description, :item_url, :user_id, :created_at, :updated_at
json.url item_url(item, format: :json)
