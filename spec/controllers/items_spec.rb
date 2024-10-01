require 'rails_helper'

RSpec.describe ItemsController do
  let(:user) { create(:user) }
  let(:valid_attributes) { 
    { title: "Test Item", description: "Test Description", item_url: "https://youtube.com/shorts/abcdefghijk", tag_list: "tag1, tag2", user_id: user.id }
  }
  let(:invalid_attributes) { 
    { title: "", description: "Test Description", item_url: "https://www.example.com", tag_list: "tag1, tag2, tag3, tag4" }
  }

  before do
    login_user(user)
  end

  describe "GET #index" do
    it "returns a success response" do
      create(:item, user: user)
      get :index
      expect(response).to be_successful
    end

    it "filters items by search parameter" do
      create(:item, user: user, title: "Search Test")
      create(:item, user: user, title: "Other Item")
      get :index, params: { search: "Search" }
      expect(assigns(:items).count).to eq(1)
    end

    it "filters items by tag" do
      item = create(:item, user: user)
      item.tag_list.add("test_tag")
      item.save
      get :index, params: { tag: "test_tag" }
      expect(assigns(:items).count).to eq(1)
    end

    it "paginates results" do
      # create_list(:item, 15, user: user)
      create_list(:item, 10, user: user)
      5.times { create(:item, user: user) }
      get :index
      expect(assigns(:items).count).to eq(10)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      item = create(:item, user: user)
      get :show, params: { id: item.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      item = create(:item, user: user)
      get :edit, params: { id: item.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Item" do
        expect {
          post :create, params: { item: valid_attributes }
        }.to change(Item, :count).by(1)
      end

      it "redirects to the items list" do
        post :create, params: { item: valid_attributes }
        expect(response).to redirect_to(items_url)
      end

      it "limits tags to 3" do
        post :create, params: { item: valid_attributes.merge(tag_list: "tag1, tag2, tag3, tag4") }
        expect(Item.last.tag_list.count).to eq(3)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with an existing item_url" do
      it "redirects to the existing item" do
        existing_item = create(:item, user: user)
        post :create, params: { item: valid_attributes.merge(item_url: existing_item.item_url) }
        expect(response).to redirect_to(item_path(existing_item))
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { title: "New Title", description: "New Description", tag_list: "tag1, tag2, tag3" }
      }

      it "updates the requested item" do
        item = Item.create!(valid_attributes)
        put :update, params: { id: item.to_param, item: new_attributes }
        item.reload
        expect(item.title).to eq("New Title")
        expect(item.description).to eq("New Description")
        expect(item.tag_list).to eq(["tag1", "tag2", "tag3"])
      end

      it "redirects to the item" do
        item = create(:item, user: user)
        put :update, params: { id: item.to_param, item: valid_attributes }
        expect(response).to redirect_to(item_url(item))
      end

      it "updates tags" do
        item = create(:item, user: user, tag_list: "old_tag")
        put :update, params: { id: item.to_param, item: valid_attributes.merge(tag_list: "new_tag1, new_tag2") }
        item.reload
        expect(item.tag_list).to eq(["new_tag1", "new_tag2"])
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        item = create(:item, user: user)
        put :update, params: { id: item.to_param, item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested item" do
      item = create(:item, user: user)
      expect {
        delete :destroy, params: { id: item.to_param }
      }.to change(Item, :count).by(-1)
    end

    it "redirects to the items list" do
      item = create(:item, user: user)
      delete :destroy, params: { id: item.to_param }
      expect(response).to redirect_to(items_url)
    end
  end

  describe "access control" do
    it "prevents access to other user's items" do
      other_user = create(:user)
      other_item = create(:item, user: other_user)
      get :show, params: { id: other_item.to_param }
      expect(response).to redirect_to(items_path)
    end
  end
end
