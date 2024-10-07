require 'rails_helper'

RSpec.describe SendListsController, type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }

  before do
    login(user)
    allow_any_instance_of(SmsSender).to receive(:send_sms).and_return(OpenStruct.new(status: 'queued'))
  end

  describe "GET /index" do
    it "returns a successful response" do
      get send_lists_path
      expect(response).to be_successful
    end

    it "paginates results" do
      create_list(:send_list, 25, user: user)
      get send_lists_path
      expect(assigns(:send_lists).count).to eq(20)
    end
  end

  describe "POST /create" do
    let(:valid_attributes) {
      FactoryBot.attributes_for(:send_list).merge(item_id: item.id)
    }

    context "with valid parameters" do
      it "creates a new SendList" do
        expect {
          post send_lists_path, params: { send_list: valid_attributes }
        }.to change(SendList, :count).by(1)
      end

      it "creates a SendList with correct attributes" do
        post send_lists_path, params: { send_list: valid_attributes }
        created_send_list = SendList.last
        expect(created_send_list.phone_number).to eq valid_attributes[:phone_number]
        expect(created_send_list.sender).to eq valid_attributes[:sender]
        expect(created_send_list.send_at).to be_within(1.second).of Time.current
        expect(created_send_list.send_as_test).to eq valid_attributes[:send_as_test]
        expect(created_send_list.item_id).to eq valid_attributes[:item_id]
        expect(created_send_list.user_id).to eq user.id
      end

      it "redirects to the send_lists path" do
        post send_lists_path, params: { send_list: valid_attributes }
        expect(response).to redirect_to(send_lists_path)
      end

      it "sends an SMS" do
        sms_sender = instance_double(SmsSender)
        allow(SmsSender).to receive(:new).and_return(sms_sender)
        expect(sms_sender).to receive(:send_sms).and_return(OpenStruct.new(status: 'queued'))

        post send_lists_path, params: { send_list: valid_attributes }
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        FactoryBot.attributes_for(:send_list, phone_number: "123", item_id: item.id)
      }

      it "does not create a new SendList" do
        expect {
          post send_lists_path, params: { send_list: invalid_attributes }
        }.not_to change(SendList, :count)
      end

      it "redirects to the items path" do
        post send_lists_path, params: { send_list: invalid_attributes }
        expect(response).to redirect_to(items_path)
      end
    end

    context "when SMS sending fails" do
      it "redirects to send_lists path with an error message" do
        sms_sender = instance_double(SmsSender)
        allow(SmsSender).to receive(:new).and_return(sms_sender)
        allow(sms_sender).to receive(:send_sms).and_raise(StandardError)

        post send_lists_path, params: { send_list: valid_attributes }
        expect(response).to redirect_to(send_lists_path)
        expect(flash[:danger]).to be_present
      end
    end
  end
end
