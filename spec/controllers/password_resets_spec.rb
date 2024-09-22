require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    context 'when email is valid' do
      it 'sends a password reset email and redirects to login path' do
        expect_any_instance_of(User).to receive(:deliver_reset_password_instructions!)
        post :create, params: { email: user.email }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq('パスワードリセットのメールを送信しました。メールをご確認ください。')
      end
    end

    context 'when email is invalid' do
      it 'redirects to new password reset path with an alert' do
        post :create, params: { email: 'nonexistent@example.com' }
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
        get :edit, params: { token: user.reset_password_token }
        expect(response).to render_template(:edit)
      end

      it 'assigns @user and @token' do
        get :edit, params: { token: user.reset_password_token }
        expect(assigns(:user)).to eq(user)
        expect(assigns(:token)).to eq(user.reset_password_token)
      end
    end

    context 'with invalid or expired token' do
      it 'redirects to new password reset path with an alert' do
        get :edit, params: { token: 'invalidtoken' }
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
        patch :update, params: { token: user.reset_password_token, user: { password: 'NewPassword1!', password_confirmation: 'NewPassword1!' } }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq('パスワードがリセットされました。')
        user.reload
        expect(user.valid_password?('NewPassword1!')).to be_truthy
      end

      it 'clears the reset password token after successful update' do
        patch :update, params: { token: user.reset_password_token, user: { password: 'NewPassword1!', password_confirmation: 'NewPassword1!' } }
        user.reload
        expect(user.reset_password_token).to be_nil
      end
    end

    context 'with invalid password params' do
      it 'does not reset the password and re-renders the edit template' do
        expect {
          patch :update, params: { token: user.reset_password_token, user: { password: 'short', password_confirmation: 'short' } }
        }.not_to change { user.reload.crypted_password }
        
        expect(response).to render_template(:edit)
        expect(assigns(:user).errors).to be_present
        expect(flash.now[:alert]).to eq('パスワードリセットに失敗しました。もう一度試してください。')
      end
    end

    context 'with invalid password format' do
      shared_examples 'invalid password' do |password|
        it 'does not reset the password and shows an error message' do
          patch :update, params: { token: user.reset_password_token, user: { password: password, password_confirmation: password } }
          expect(response).to render_template(:edit)
          expect(flash.now[:alert]).to eq('パスワードリセットに失敗しました。もう一度試してください。')
          expect(assigns(:user).errors[:password]).to include('は最低6文字で、数字と大文字を含む必要があります。')
        end
      end

      it_behaves_like 'invalid password', 'Short1'
      it_behaves_like 'invalid password', 'nouppercase1'
      it_behaves_like 'invalid password', 'NoNumber'
    end

    it 'logs an error when password change fails' do
      allow_any_instance_of(User).to receive(:change_password).and_return(false)
      expect(Rails.logger).to receive(:error).with(/パスワードの変更に失敗しました/)
      patch :update, params: { token: user.reset_password_token, user: { password: 'NewPassword1!', password_confirmation: 'NewPassword1!' } }
    end
  end
end
