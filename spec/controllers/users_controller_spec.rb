require 'rails_helper'

RSpec.describe UsersController, type: :request do
  describe "GET /users/new" do
    it "returns http success" do
      get new_user_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user and redirects to the root path" do
        expect {
          post users_path, params: { user: { name: "Test User", email: "test@example.com", password: "Password1!", password_confirmation: "Password1!" } }
          puts response.body  # エラーメッセージの確認用
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("ユーザー登録が成功し、ログインしました")
      end
    end

    context "with invalid parameters" do
      it "does not create a user and re-renders the new template" do
        expect {
          post users_path, params: { user: { name: "", email: "test@example.com", password: "password", password_confirmation: "password" } }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("ユーザー登録に失敗しました")
      end
    end
  end

  # describe "PATCH /users/:uuid" do
  #   let(:user) { create(:user) }
  
  #   before do
  #     login_user(user)
  #   end
  
  #   context "with valid attributes" do
  #     it "updates the user and redirects" do
  #       patch user_path(user.uuid), params: { user: { name: "Updated Name" } }
  #       expect(response).to redirect_to(user_path(user.uuid))
  #       follow_redirect!
  #       expect(response.body).to include("更新しました")
  #     end
  #   end
  
  #   context "with invalid attributes" do
  #     it "does not update the user and re-renders the edit template" do
  #       patch user_path(user.uuid), params: { user: { email: nil } }
  #       expect(response).to render_template(:edit)
  #       expect(response).to have_http_status(:unprocessable_entity)
  #     end
  #   end
  # end
  
  # describe "PATCH /users/:uuid/update_password" do
  #   let(:user) { create(:user, password: 'old_password') }
  
  #   before do
  #     login_user(user)
  #   end
  
  #   context "with valid password change" do
  #     it "updates the password and redirects to the login path" do
  #       patch update_password_user_path(user.uuid), params: { user: { password: "new_password", password_confirmation: "new_password" } }
  #       expect(response).to redirect_to(login_path)
  #       follow_redirect!
  #       expect(response.body).to include('パスワードが更新されました。再ログインしてください。')
  #     end
  #   end
  
  #   context "with password mismatch" do
  #     it "does not update the password and redirects to edit password path" do
  #       patch update_password_user_path(user.uuid), params: { user: { password: "new_password", password_confirmation: "different" } }
  #       expect(response).to redirect_to(edit_password_user_path(user.uuid))
  #       follow_redirect!
  #       expect(response.body).to include('入力されたパスワードが一致しません。')
  #     end
  #   end
  # end  
end
