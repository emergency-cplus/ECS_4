require 'rails_helper'

RSpec.describe UsersController do
  let(:user) { create(:user, password: 'OldPassword1!', password_confirmation: 'OldPassword1!') }
  
  describe 'GET #show' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context 'when the logged in user is the correct user' do
      before do
        login_user(user)
        get user_path(user.uuid)  # 修正: パスを直接指定
      end
    end

    context 'when the logged in user is not the correct user' do
      before do
        login_user(other_user)
        get user_path(user.uuid)  # 修正: パスを直接指定
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(login_path) # ログインページへのリダイレクトを期待
      end
    end
  end
  
  describe "GET /users/new" do
    it "returns http success" do
      get new_user_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user and redirects to the root path" do
        expect do
          post users_path, params: { user: { name: "Test User", email: "test@example.com", password: "Password1!", password_confirmation: "Password1!" } }
          puts response.body # エラーメッセージの確認用
        end.to change(User, :count).by(1)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("ユーザー登録が成功し、ログインしました")
      end
    end

    context "with invalid parameters" do
      it "does not create a user and re-renders the new template" do
        expect do
          post users_path, params: { user: { name: "", email: "test@example.com", password: "password", password_confirmation: "password" } }
        end.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("ユーザー登録に失敗しました")
      end
    end
  end

  describe "PATCH /users/:uuid" do
    let(:user) { create(:user, password: 'Test1234!', password_confirmation: 'Test1234!') }

    before do
      post login_path, params: { email: user.email, password: 'Test1234!' }
    end

    context "with valid attributes" do
      it "updates the user and redirects" do
        patch user_path(user.uuid), params: { user: { name: "Updated Name" } }
        expect(response).to redirect_to(user_path(user.uuid))
        follow_redirect!
        expect(response.body).to include("更新しました")
      end
    end

    context "with invalid attributes" do
      it "does not update the user and re-renders the edit template" do
        patch user_path(user.uuid), params: { user: { email: nil } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
  
  describe "PATCH /users/:uuid/update_password" do
    before do
      login_user(user)
    end

    context "with valid password change" do
      let(:new_password_params) do
        {
          user: {
            password: "NewPassword1!",
            password_confirmation: "NewPassword1!"
          }
        }
      end

      it "updates the password, logs out the user and redirects to the login path" do
        patch update_password_user_path(user.uuid), params: new_password_params
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include('パスワードが更新されました。再ログインしてください。')
        expect(user.reload.valid_password?('NewPassword1!')).to be_truthy
      end
    end

    context "with password mismatch" do
      let(:mismatch_password_params) do
        {
          user: {
            password: "NewPassword1!",
            password_confirmation: "DifferentPassword1!"
          }
        }
      end

      it "does not update the password and redirects back to the password edit page with an error message" do
        patch update_password_user_path(user.uuid), params: mismatch_password_params
        expect(response).to redirect_to(edit_password_user_path(user.uuid))
        follow_redirect!
        expect(response.body).to include('入力されたパスワードが一致しません。')
      end
    end

    context "with the same password as old" do
      let(:same_password_params) do
        {
          user: {
            password: "OldPassword1!",
            password_confirmation: "OldPassword1!"
          }
        }
      end

      it "does not update the password and redirects back to the password edit page with an error message" do
        patch update_password_user_path(user.uuid), params: same_password_params
        expect(response).to redirect_to(edit_password_user_path(user.uuid))
        follow_redirect!
        expect(response.body).to include('新しいパスワードが以前のパスワードと同じです。')
      end
    end
  end

  def login_user(user)
    post login_path, params: { email: user.email, password: 'OldPassword1!' }
  end
end
