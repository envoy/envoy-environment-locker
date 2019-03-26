class QueueController < ApplicationController
  skip_before_action :verify_authenticity_token

  def perform_action
    begin
      validate_token
      QueueManager.new(DashCommand.new(params)).perform
      head 200
    rescue => error
      Rails.logger.info(error.message)
      puts error.backtrace
      head 200
    end
  end

  private

  def validate_token
    raise "Invalid token" if params[:token] != ENV["SLACK_SECRET_TOKEN"]
  end
end
