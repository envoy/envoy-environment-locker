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

  def button_hook
    begin
      pld = JSON.parse(params[:payload])
      validate_token(pld["token"])
      ButtonResponse.new(pld).handle!
    rescue => error
      Rails.logger.info(error.message)
      puts error.backtrace
    ensure
      head 200
    end
  end

  private

  def validate_token(token = params[:token])
    raise "Invalid token" if token != ENV["SLACK_SECRET_TOKEN"]
  end
end
