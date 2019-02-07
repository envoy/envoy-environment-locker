require 'rails_helper'

RSpec.describe QueueManager do
  before do
    allow(SlackNotifier).to receive(:new).and_return(slack_notifier)
  end

  describe "#perform_action" do
    subject { described_class.new(user_id).perform(action) }

    let(:user_id) { "U8C70UGDM" }
    let(:user_id_2) { "U8C70UGDA" }
    let(:user_id_3) { "U8C70UGDB" }
    let(:slack_notifier) { double(:slack_notifier, post: true) }

    describe "locking the queue" do
      let(:action) { "/lock" }

      describe "for an empty queue" do
        it "posts the expected result" do
          subject

          expect(SlackNotifier).to have_received(:new).with([user_id])
          expect(slack_notifier).to have_received(:post)
        end
      end

      describe "for an existing queue" do
        before do
          REDIS.hset('env_queue', user_id_2, 1549410757)
          REDIS.hset('env_queue', user_id_3, 1549411384)
        end

        it "posts the expected result" do
          subject

          expect(SlackNotifier).to have_received(:new).with([user_id_2, user_id_3, user_id])
          expect(slack_notifier).to have_received(:post)
        end
      end
    end

    describe "unlocking the queue" do
      let(:action) { "/unlock" }

      describe "for an empty queue" do
        it "posts the expected result" do
          subject

          expect(SlackNotifier).to have_received(:new).with([])
          expect(slack_notifier).to have_received(:post)
        end
      end

      describe "for an existing queue" do
        before do
          REDIS.hset('env_queue', user_id_2, 1549410757)
          REDIS.hset('env_queue', user_id, 1549410777)
          REDIS.hset('env_queue', user_id_3, 1549411384)
        end

        it "posts the expected result" do
          subject

          expect(SlackNotifier).to have_received(:new).with([user_id_2, user_id_3])
          expect(slack_notifier).to have_received(:post)
        end
      end
    end

    describe "displaying the queue" do
      let(:action) { "/queue" }

      describe "for an empty queue" do
        it "posts the expected result" do
          subject

          expect(SlackNotifier).to have_received(:new).with([])
          expect(slack_notifier).to have_received(:post)
        end
      end

      describe "for an existing queue" do
        before do
          REDIS.hset('env_queue', user_id_2, 1549410757)
          REDIS.hset('env_queue', user_id, 1549410777)
          REDIS.hset('env_queue', user_id_3, 1549411384)
        end

        it "posts the expected result" do
          subject

          expect(SlackNotifier).to have_received(:new).with([user_id_2, user_id, user_id_3])
          expect(slack_notifier).to have_received(:post)
        end
      end
    end
  end
end
