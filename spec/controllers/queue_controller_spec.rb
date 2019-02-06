require 'rails_helper'

RSpec.describe QueueController, type: :controller do
  before do
    stub_env("SLACK_SECRET_TOKEN", "abcdefg")
  end

  describe ".perform_action" do
    subject { post :perform_action, params: params }

    let(:params) do
      {
        user_id: user_id,
        command: command,
        token: token
      }
    end
    let(:user_id) { "blah" }
    let(:command) { "/lock" }

    describe "with a good token" do
      let(:token) { "abcdefg" }

      it "returns a 200" do
        subject

        expect(response.code).to eq("200")
      end
    end

    describe "with a bad token" do
      let(:token) { "zzzzzzzz" }

      it "informs the client that there was an issue with the request" do
        subject

        expect(response.code).to eq("400")
        expect(JSON.parse(response.body)["text"]).to eq("There was a problem with the request")
      end
    end
  end
end
