require "rails_helper"
require "securerandom"

RSpec.describe ButtonResponse do
  let(:payload) do
    lambda do |action|
      {
        type: "interactive_message",
        actions: [{ name: "extend_action", type: "button", "value" => action }],
        callback_id: "action_api",
        channel: { "id" => "some-channel-id", name: "directmessage" },
        user: { "id" => "some-user-id", name: "nhocki" },
        action_ts: "action-ts-id",
        message_ts: "message-ts-id",
      }
    end
  end

  let(:service) { Service.new("api") }

  before do
    allow(SlackNotifier).to receive(:new).and_return(double(:slack_notifier, remove_attachments: true))
    service.lock(user: "some-user-id", seconds: 30)
  end

  describe "#handle!" do
    it "adds more time to lock when requested" do
      resp = ButtonResponse.new(payload.("extend"))
      resp.handle!
      expect(service.ttl).to be_within(2).of(930) # 15 minutes is 900 seconds.
    end

    it "unblocks the service from button" do
      resp = ButtonResponse.new(payload.("unlock"))
      resp.handle!
      expect(service).not_to be_locked
    end
  end
end
