# spec/models/item_spec.rb
require 'rails_helper'

RSpec.describe Item do
  let(:user) { create(:user) }
  let(:item) { build(:item, user: user) }

  describe 'バリデーション' do
    it 'ユーザー、タイトル、有効なYouTube Shorts URLがあれば有効であること' do
      expect(item).to be_valid
    end

    it 'ユーザーがなければ無効であること' do
      item.user = nil
      expect(item).not_to be_valid
    end

    it 'タイトルがなければ無効であること' do
      item.title = nil
      expect(item).not_to be_valid
    end

    it 'アイテムURLがなければ無効であること' do
      item.item_url = nil
      expect(item).not_to be_valid
    end

    it '無効なURLフォーマットの場合は無効であること' do
      item.item_url = 'https://www.example.com'
      expect(item).not_to be_valid
    end

    it '有効なYouTube Shorts URLの場合は有効であること' do
      item.item_url = 'https://www.youtube.com/shorts/abcdefgh'
      expect(item).to be_valid
    end

    it 'アイテムURLが重複していると無効であること' do
      existing_item = create(:item, item_url: 'https://www.youtube.com/shorts/duplicate')
      item.item_url = 'https://www.youtube.com/shorts/duplicate'
      expect(item).not_to be_valid
    end
  end

  describe '関連付け' do
    it 'ユーザーに属していること' do
      expect(item.user).to eq(user)
    end

    it '複数のsend_listsを持つこと' do
      expect(item).to respond_to(:send_lists)
    end
  end

  describe 'タグ付け' do
    it 'タグを追加できること' do
      item.tag_list.add('タグ1', 'タグ2')
      expect(item.tag_list).to contain_exactly('タグ1', 'タグ2')
    end

    it '3つ以上のタグを追加すると無効になること' do
      item.tag_list.add('タグ1', 'タグ2', 'タグ3', 'タグ4')
      expect(item).not_to be_valid
    end
  end
end
