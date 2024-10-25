require 'rails_helper'

RSpec.describe "PasswordResets" do
  describe 'GET #new' do
    it 'renders the new template' do
      get new_password_reset_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('パスワードリセット')
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    context 'when email is valid' do
      it 'sends a password reset email and redirects to login path' do
        expect_any_instance_of(User).to receive(:deliver_reset_password_instructions!)
        post password_resets_path, params: { email: user.email }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq('パスワードリセットのメールを送信しました。メールをご確認ください。')
      end
    end

    context 'when email is invalid' do
      it 'redirects to new password reset path with an alert' do
        post password_resets_path, params: { email: 'nonexistent@example.com' }
        expect(response).to redirect_to(new_password_reset_path)
        expect(flash[:alert]).to eq('指定されたメールアドレスは見つかりませんでした。')
      end
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }

    context 'with valid token' do
      before do
        user.deliver_reset_password_instructions!
      end

      it 'renders the edit template' do
        get edit_password_reset_path(user.reset_password_token)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('パスワード再設定')
      end
    end

    context 'with invalid token' do
      it 'redirects to new password reset path' do
        get edit_password_reset_path('invalid_token')
        expect(response).to redirect_to(new_password_reset_path)
        expect(flash[:alert]).to eq('無効または期限切れのトークンです。もう一度試してください。')
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }

    before do
      user.deliver_reset_password_instructions!
    end

    context 'with valid password params' do
      it 'resets the password and redirects to the login path' do
        patch password_reset_path(user.reset_password_token), params: { user: { password: 'NewPassword1!', password_confirmation: 'NewPassword1!' } }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq('パスワードがリセットされました。')
        user.reload
        expect(user.valid_password?('NewPassword1!')).to be_truthy
      end

      it 'clears the reset password token after successful update' do
        patch password_reset_path(user.reset_password_token), params: { user: { password: 'NewPassword1!', password_confirmation: 'NewPassword1!' } }
        user.reload
        expect(user.reset_password_token).to be_nil
      end
    end

    context 'with invalid password params' do
      it 'does not reset the password and re-renders the edit template' do
        expect do
          patch password_reset_path(user.reset_password_token), params: { user: { password: 'short', password_confirmation: 'short' } }
        end.not_to(change { user.reload.crypted_password })
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('パスワードリセットに失敗しました。もう一度試してください。')
      end
    end

    context 'with invalid password format' do
      shared_examples 'invalid password' do |password|
        it 'does not reset the password and shows an error message' do
          patch password_reset_path(user.reset_password_token), params: { user: { password:, password_confirmation: password } }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('パスワードリセットに失敗しました。もう一度試してください。')
        end
      end

      it_behaves_like 'invalid password', 'short'
      it_behaves_like 'invalid password', 'onlylowercase123'
      it_behaves_like 'invalid password', 'ONLYUPPERCASE123'
    end

    it 'logs an error when password change fails' do
      allow_any_instance_of(User).to receive(:change_password).and_return(false)
      expect(Rails.logger).to receive(:error).with(/パスワードの変更に失敗しました/)
      patch password_reset_path(user.reset_password_token), params: { user: { password: 'NewPassword1!', password_confirmation: 'NewPassword1!' } }
    end
  end
end
