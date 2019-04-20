class QueueController < ApplicationController
  skip_before_action :verify_authenticity_token

  def perform_action
    begin
      validate_token
      QueueManager.new(DashCommand.new(params)).perform
    rescue => error
      Rails.logger.error(error.message)
      Rails.logger.error(error.backtrace)
    ensure
      head 200
    end
  end

  private

  def validate_token
    raise "Invalid token" if params[:token] != ENV["SLACK_SECRET_TOKEN"]
  end
end
