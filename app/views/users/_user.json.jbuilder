json.extract! user, :id, :new, :edit, :show, :created_at, :updated_at
json.url user_url(user, format: :json)
