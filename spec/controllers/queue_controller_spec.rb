require 'rails_helper'

RSpec.describe QueueController, type: :controller do
  describe ".action" do
    subject { post :action, params: params }

    let(:params) do
      {
        user_id: user_id
      }
    end
    let(:user_id) { "blah" }

    it "returns a 200" do
      subject
      
      expect(response.code).to eq("200")
    end
  end
end
