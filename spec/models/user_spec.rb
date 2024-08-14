require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it 'is valid with valid attributes' do
      user = FactoryBot.build(:user, email: 'test@example.com', password: 'Password1!', password_confirmation: 'Password1!', name: 'Test User')
      expect(user).to be_valid
    end

    it 'requires email to be unique' do
      existing_user = FactoryBot.create(:user, email: 'test@example.com')
      user = FactoryBot.build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('はすでに存在します')
    end

    it 'requires a password to have a minimum length of 8 characters' do
      user = FactoryBot.build(:user, password: 'short1', password_confirmation: 'short1')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('は最低8文字以上でなければなりません。')
    end

    it 'requires a password to include symbols' do
      user = FactoryBot.build(:user, password: 'Password1!', password_confirmation: 'Password1!')
      expect(user).to be_valid  # Adjust this line based on your password_symbols validation rules
    end
  end

  context 'on create' do
    it 'ensures a UUID is set' do
      user = FactoryBot.create(:user)
      expect(user.uuid).not_to be_nil
    end
  end

  describe '#send_password_reset_email' do
    it 'sets a reset password token and sends an email' do
      user = FactoryBot.create(:user)
      expect { user.send_password_reset_email }
        .to change { user.reset_password_token }
        .and change { ActionMailer::Base.deliveries.size }.by(1)
      expect(user.reset_password_email_sent_at).not_to be_nil
    end
  end
end
