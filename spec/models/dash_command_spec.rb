require "rails_helper"

RSpec.describe DashCommand do
  describe "parsing #text" do
    describe "timing information" do
      let(:minute) { 60 }
      let(:hour) { 60 * minute }

      it "gets timing information from `text`" do
        cases = [
          ["api for 10 minutes", 10 * minute],
          ["api for 5 minutes", 5 * minute],
          ["api for 1 minute", 1 * minute],
          ["api for 1 hour", 1 * hour],
          ["api for 2 hours", 2 * hour],
        ]

        cases.each do |tc|
          dc = DashCommand.new(text: tc.first)
          expect(dc.seconds).to eq(tc.last)
        end
      end

      it "defaults to 30 minutes" do
        dc = DashCommand.new(text: "api")
        expect(dc.seconds).to eq(30 * minute)
      end

      it "only accepts hours and minutes" do
        dc = DashCommand.new(text: "api for 3 days")
        expect(dc).not_to be_valid
      end
    end

    it "gets service name from `text`" do
      cases = ["api for 10 minutes", "api for 5 minutes", "api for 1 minute", "api for 1 hour", "api for 2 hours"]
      cases.each do |tc|
        dc = DashCommand.new(text: tc)
        expect(dc.service).to eq("api")
      end
    end
  end
end

# Parameters: {"token"=>"in8g68Jq7T6FimKNeiH9mx2K", "team_id"=>"T024GCGSK", "team_domain"=>"splicechat", "channel_id"=>"C2JQQKQSF", "channel_name"=>"ask-a-bot-staging", "user_id"=>"U30FZH0MD", "user_name"=>"nhocki", "command"=>"/lock", "text"=>"api for 10 minutes", "response_url"=>"https://hooks.slack.com/commands/T024GCGSK/614106738917/zvr2rSA6HrKtnY6TJTyzxhAD", "trigger_id"=>"615985463175.2152424903.2b0570fbd5934dda21836c1770d7f32b"}
