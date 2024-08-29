# spec/requests/user_sessions_spec.rb
require 'rails_helper'

RSpec.describe "UserSessions", type: :request do
  describe "GET /login" do
    it "renders the login page" do
      get login_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /login" do
    let(:user) { FactoryBot.create(:user, password: 'Password1!') }

    context "with valid credentials" do
      it "logs the user in and redirects to the root path" do
        post login_path, params: { email: user.email, password: 'Password1!' }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("ログインしました")
      end
    end

    context "with invalid credentials" do
      it "does not log the user in and re-renders the login page" do
        post login_path, params: { email: "wrong@example.com", password: "wrongpassword" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /logout" do
    let(:user) { FactoryBot.create(:user, password: 'Password1!') }

    before do
      post login_path, params: { email: user.email, password: 'Password1!' }
    end

    it "logs the user out and redirects to the root path" do
      delete logout_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:success]).to eq("ログアウトしました")
    end
  end
end
