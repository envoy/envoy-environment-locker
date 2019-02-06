require 'rails_helper'

RSpec.describe QueueManager do
  describe "#perform_action" do
    subject { described_class.new(user_id).perform(action) }

    let(:user_id) { "U8C70UGDM" }
    let(:user_id_2) { "U8C70UGDA" }
    let(:user_id_3) { "U8C70UGDB" }

    describe "locking the queue" do
      let(:action) { "/lock" }

      describe "for an empty queue" do
        it "returns the expected result" do
          expected_result = {
            text: "Current queue for staging: <@U8C70UGDM>"
          }

          expect(subject).to eq(expected_result)
        end
      end

      describe "for an existing queue" do
        before do
          REDIS.hset('env_queue', user_id_2, 1549410757)
          REDIS.hset('env_queue', user_id_3, 1549411384)
        end

        it "returns the expected result" do
          expected_result = {
            text: "Current queue for staging: <@U8C70UGDA>, <@U8C70UGDB>, <@U8C70UGDM>"
          }

          expect(subject).to eq(expected_result)
        end
      end
    end

    describe "unlocking the queue" do
      let(:action) { "/unlock" }

      describe "for an empty queue" do
        it "returns the expected result" do
          expected_result = {
            text: "Current queue for staging: "
          }

          expect(subject).to eq(expected_result)
        end
      end

      describe "for an existing queue" do
        before do
          REDIS.hset('env_queue', user_id_2, 1549410757)
          REDIS.hset('env_queue', user_id, 1549410777)
          REDIS.hset('env_queue', user_id_3, 1549411384)
        end

        it "returns the expected result" do
          expected_result = {
            text: "Current queue for staging: <@U8C70UGDA>, <@U8C70UGDB>"
          }

          expect(subject).to eq(expected_result)
        end
      end
    end
  end
end
