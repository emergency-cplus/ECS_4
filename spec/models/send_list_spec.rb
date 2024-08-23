# spec/models/send_list_spec.rb
require 'rails_helper'

RSpec.describe SendList, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      send_list = build(:send_list)
      expect(send_list).to be_valid
    end

    it 'is not valid without a phone number' do
      send_list = build(:send_list, phone_number: nil)
      expect(send_list).not_to be_valid
      expect(send_list.errors[:phone_number]).to include("を入力してください")
    end

    it 'is not valid without a sender' do
      send_list = build(:send_list, sender: nil)
      expect(send_list).not_to be_valid
      expect(send_list.errors[:sender]).to include("を入力してください")
    end
  end
end
