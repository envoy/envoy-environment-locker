require 'rails_helper'

RSpec.describe SlackNotifier do
  before do
    allow(Slack::Notifier).to receive(:new).and_return(notifier)
  end

  describe "#post" do
    subject { described_class.new(queue).post }

    let(:queue) { [] }
    let(:notifier) { double(:notifier, post: true) }
    let(:expected_payload) do
      { text: expected_text }
    end
    let(:user_id) { "my_user_id" }
    let(:user_id_2) { "my_user_id_2" }

    describe "with an empty queue" do
      let(:expected_text) { "Staging is unclaimed!" }

      it "pings with the correct payload" do
        subject

        expect(notifier).to have_received(:post).with(expected_payload)
      end
    end
    describe "with a queue containing a single user" do
      let(:queue) { [user_id] }
      let(:expected_text) { "Current queue for staging:\n1st: <@#{user_id}> _(currently holding staging)_" }

      it "pings with the correct payload" do
        subject

        expect(notifier).to have_received(:post).with(expected_payload)
      end
    end

    describe "with a queue containing multiple users" do
      let(:queue) { [user_id, user_id_2] }
      let(:expected_text) { "Current queue for staging:\n1st: <@#{user_id}> _(currently holding staging)_\n2nd: <@#{user_id_2}>" }

      it "pings with the correct payload" do
        subject

        expect(notifier).to have_received(:post).with(expected_payload)
      end
    end
  end
end
