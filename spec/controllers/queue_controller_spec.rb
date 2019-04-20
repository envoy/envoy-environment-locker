require "rails_helper"

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
        token: token,
        text: "#{srv_name} for #{minutes} minutes",
      }
    end
    let(:user_id) { "blah" }
    let(:command) { "/lock" }
    let(:srv_name) { "whatever" }
    let(:minutes) { "10" }
    let(:slack_notifier) { double(:slack_notifier, service_status: true) }

    describe "`/lock`ing the queue" do
      let(:token) { "abcdefg" }

      it "returns a 200 OK and posts the current queue" do
        post :perform_action, params: params

        service = Service.new(srv_name)
        expect(service).to be_locked
        expect(service.ttl).to be_within(5).of(600)
        expect(service.lock_owner).to eql(user_id)
        expect(response.status).to eq(200)
        expect(slack_notifier).to have_received(:service_status)
      end

      describe "`/unlock`ing the queue" do
        let(:command) { "/unlock" }

        it "returns a 200 OK and unlocks the service" do
          service = Service.new(srv_name)
          service.lock(user: user_id, seconds: 400)

          post :perform_action, params: params

          expect(service).not_to be_locked
          expect(response.status).to eq(200)
          expect(slack_notifier).to have_received(:service_status)
        end
      end
    end

    describe "with a bad token" do
      let(:token) { "zzzzzzzz" }

      it "returns a 200 OK, but does not post a message to the channel" do
        post :perform_action, params: params

        expect(SlackNotifier).not_to have_received(:new)
        expect(response.status).to eq(200)
      end
    end
  end
end
