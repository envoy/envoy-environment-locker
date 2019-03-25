class QueueController < ApplicationController
  skip_before_action :verify_authenticity_token

  def perform_action
    begin
      validate_token
      QueueManager.new(service: service, user_id: user_id).perform(command)
      head 200
    rescue => error
      Rails.logger.info(error.message)
      head 200
    end
  end

  private

  def validate_token
    raise "Invalid token" if token != ENV["SLACK_SECRET_TOKEN"]
  end

  def user_id
    params[:user_id]
  end

  def service
    if params[:text]
      params[:text].split.first
    else
      "api"
    end
  end

  def command
    params[:command]
  end

  def token
    params[:token]
  end
end
