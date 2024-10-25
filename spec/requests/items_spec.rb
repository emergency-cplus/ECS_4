require 'rails_helper'

RSpec.describe "Items" do
  let(:user) { create(:user) }
  let(:valid_attributes) do 
    { title: "Test Item", description: "Test Description", item_url: "https://youtube.com/shorts/abcdefghijk", tag_list: "tag1, tag2", user_id: user.id }
  end
  let(:invalid_attributes) do 
    { title: "", description: "Test Description", item_url: "https://www.example.com", tag_list: "tag1, tag2, tag3, tag4" }
  end

  before do
    login(user)
  end

  describe "GET /items" do
    it "returns a success response" do
      create(:item, user:)
      get items_path
      expect(response).to be_successful
    end

    it "filters items by search parameter" do
      create(:item, title: "Searchable Item", user:)
      create(:item, title: "Another Item", user:)
      get items_path, params: { search: "Searchable" }
      expect(response.body).to include("Searchable Item")
      expect(response.body).not_to include("Another Item")
    end

    it "filters items by tag" do
      create(:item, title: "Tagged Item", user:, tag_list: "test_tag")
      create(:item, title: "Untagged Item", user:)
      get items_path, params: { tag: "test_tag" }
      expect(response.body).to include("Tagged Item")
      expect(response.body).not_to include("Untagged Item")
    end

    it "paginates results" do
      create_list(:item, 11, user:)
      get items_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('class="pagination join m-3"')
      expect(response.body).to include('次へ')
      expect(response.body).to include('href="/items?page=2"')
    end
    
  end

  describe "GET /items/:id" do
    it "returns a success response" do
      item = create(:item, user:)
      get item_path(item)
      expect(response).to be_successful
    end
  end

  describe "GET /items/new" do
    it "returns a success response" do
      get new_item_path
      expect(response).to be_successful
    end
  end

  describe "GET /items/:id/edit" do
    it "returns a success response" do
      item = create(:item, user:)
      get edit_item_path(item)
      expect(response).to be_successful
    end
  end

  describe "POST /items" do
    context "with valid params" do
      it "creates a new Item" do
        expect do
          post items_path, params: { item: valid_attributes }
        end.to change(Item, :count).by(1)
      end

      it "redirects to the items list" do
        post items_path, params: { item: valid_attributes }
        expect(response).to redirect_to(items_path)
      end

      it "limits tags to 3" do
        post items_path, params: { item: valid_attributes.merge(tag_list: "tag1, tag2, tag3, tag4") }
        expect(Item.last.tags.count).to eq(3)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable entity status" do
        post items_path, params: { item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with an existing item_url" do
      it "redirects to the existing item" do
        existing_item = create(:item, item_url: "https://youtube.com/shorts/existingurl")
        post items_path, params: { item: valid_attributes.merge(item_url: "https://youtube.com/shorts/existingurl") }
        expect(response).to redirect_to(item_path(existing_item))
      end
    end
  end

  describe "PATCH /items/:id" do
    context "with valid params" do
      let(:new_attributes) do
        { title: "Updated Title" }
      end

      it "updates the requested item" do
        item = create(:item, user:)
        patch item_path(item), params: { item: new_attributes }
        item.reload
        expect(item.title).to eq("Updated Title")
      end

      it "redirects to the item" do
        item = create(:item, user:)
        patch item_path(item), params: { item: new_attributes }
        expect(response).to redirect_to(item_path(item))
      end
    end

    context "with invalid params" do
      it "returns an unprocessable entity status" do
        item = create(:item, user:)
        patch item_path(item), params: { item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /items/:id" do
    it "destroys the requested item" do
      item = create(:item, user:)
      expect do
        delete item_path(item)
      end.to change(Item, :count).by(-1)
    end

    it "redirects to the items list" do
      item = create(:item, user:)
      delete item_path(item)
      expect(response).to redirect_to(items_path)
    end
  end
end
