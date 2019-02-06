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

      it "returns a 200 with the current queue" do
        subject

        expect(response.code).to eq("200")
        expect(JSON.parse(response.body)["text"]).to eq("Current queue for staging: <@#{user_id}>")
      end

      describe "with an empty queue" do
        let(:command) { "/queue" }

        it "returns a 200 with the empty queue message" do
          subject

          expect(response.code).to eq("200")
          expect(JSON.parse(response.body)["text"]).to eq("Staging is unclaimed!")
        end
      end
    end

    describe "with a bad token" do
      let(:token) { "zzzzzzzz" }

      it "returns a 200, but informs the client that there was an issue with the request" do
        subject

        expect(response.code).to eq("200")
        expect(JSON.parse(response.body)["text"]).to eq("There was a problem with the request")
      end
    end
  end
end
