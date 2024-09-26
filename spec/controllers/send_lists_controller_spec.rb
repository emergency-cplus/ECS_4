require 'rails_helper'

RSpec.describe SendListsController, type: :controller do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }
  let(:valid_attributes) { { phone_number: "09012345678", sender_name: "Test Sender", item_id: item.id, send_as_test: 'off' } }
  let(:invalid_attributes) { { phone_number: "090-1234-5678", sender_name: "Test Sender", item_id: item.id } }

  before do
    login_user(user)
  end

  describe "GET #index" do
    it "returns a success response and paginates results" do
      create_list(:send_list, 30, user: user)
      get :index
      expect(response).to be_successful
      expect(assigns(:send_lists).count).to eq(20)
    end

    it "orders send_lists by created_at in descending order" do
      old_send_list = create(:send_list, user: user, created_at: 2.days.ago)
      new_send_list = create(:send_list, user: user, created_at: 1.day.ago)
      get :index
      expect(assigns(:send_lists)).to eq([new_send_list, old_send_list])
    end
  end

  # ... (other existing tests)

  describe "POST #create" do
    let(:sms_sender) { instance_double(SmsSender) }
    let(:message_template) { "Test message template" }
    let(:item_url) { "http://example.com/item" }

    before do
      allow(SmsSender).to receive(:new).and_return(sms_sender)
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:message_template).and_return(message_template)
      allow(Item).to receive(:find).and_return(item)
      allow(item).to receive(:item_url).and_return(item_url)
    end

    context "with valid params" do
      before do
        allow(sms_sender).to receive(:send_sms).and_return(OpenStruct.new(status: 'queued'))
      end

      it "creates a new SendList" do
        expect { post :create, params: valid_attributes }.to change(SendList, :count).by(1)
      end

      it "sends SMS with correct body" do
        expected_body = "#{message_template} Check this out: #{item_url}"
        expect(sms_sender).to receive(:send_sms).with(hash_including(body: expected_body))
        post :create, params: valid_attributes
      end

      it "handles test sending" do
        post :create, params: valid_attributes.merge(send_as_test: 'on')
        expect(SendList.last.send_as_test).to be true
      end
    end

    context "with invalid params" do
      it "does not create a new SendList and redirects to items path" do
        expect { post :create, params: invalid_attributes }.not_to change(SendList, :count)
        expect(response).to redirect_to(items_path)
        expect(flash[:danger]).to be_present
      end
    end

    context "when SMS sending fails" do
      before do
        allow(sms_sender).to receive(:send_sms).and_return(OpenStruct.new(status: 'failed'))
      end

      it "redirects to send_lists path with an error message" do
        post :create, params: valid_attributes
        expect(response).to redirect_to(send_lists_path)
        expect(flash[:danger]).to eq('SMSの送信に失敗しました。')
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(sms_sender).to receive(:send_sms).and_raise(StandardError.new("Unexpected error"))
      end

      it "handles the error and redirects to send_lists path" do
        post :create, params: valid_attributes
        expect(response).to redirect_to(send_lists_path)
        expect(flash[:danger]).to eq('SMS送信中にエラーが発生しました。')
      end
    end
  end

  context "when user is not authenticated" do
    before do
      logout_user
    end

    it "redirects to login page for all actions" do
      get :index
      expect(response).to redirect_to(login_path)

      get :show, params: { id: 1 }
      expect(response).to redirect_to(login_path)

      post :create, params: valid_attributes
      expect(response).to redirect_to(login_path)
    end
  end
end
