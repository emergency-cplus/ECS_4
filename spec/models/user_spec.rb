# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it 'is valid with a valid email and password' do
      user = User.new(
        email: 'test@example.com',
        password: 'Password123!',  # このパスワードは英字、数字、記号を含む8文字以上
        password_confirmation: 'Password123!',  # パスワード確認を追加
        name: 'Test User'  # ユーザー名を追加
      )
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = User.new(password: 'password123', name: 'Test User')
      expect(user).not_to be_valid
    end

    it 'is invalid without a password' do
      user = User.new(email: 'test@example.com', name: 'Test User')
      expect(user).not_to be_valid
    end
  end
end
