require 'rails_helper'

RSpec.describe QueueController, type: :controller do
  before do
    stub_env("SLACK_SECRET_TOKEN", "abcdefg")
    allow(SlackNotifier).to receive(:new).and_return(slack_notifier)
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
    let(:slack_notifier) { double(:slack_notifier, post: true) }

    describe "with a good token" do
      let(:token) { "abcdefg" }

      it "returns a 200 and posts the current queue" do
        subject

        expect(response.code).to eq("200")
        expect(SlackNotifier).to have_received(:new).with([user_id])
        expect(slack_notifier).to have_received(:post)
      end

      describe "with an empty queue" do
        let(:command) { "/queue" }

        it "returns a 200 and posts the empty queue message" do
          subject

          expect(response.code).to eq("200")
          expect(SlackNotifier).to have_received(:new).with([])
          expect(slack_notifier).to have_received(:post)
        end
      end
    end

    describe "with a bad token" do
      let(:token) { "zzzzzzzz" }

      it "returns a 200, but does not post a message to the channel" do
        subject

        expect(SlackNotifier).not_to have_received(:new)
        expect(slack_notifier).not_to have_received(:post)
      end
    end
  end
end
