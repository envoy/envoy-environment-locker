class QueueController < ApplicationController
  skip_before_action :verify_authenticity_token

  def perform_action
    begin
      validate_token
      render json: QueueManager.new(user_id).perform(command)
    rescue => error
      Rails.logger.info(error.message)
      render json: { text: "There was a problem with the request" }
    end
  end

  private

  def validate_token
    raise "Invalid token" if token != ENV["SLACK_SECRET_TOKEN"]
  end

  def user_id
    params[:user_id]
  end

  def command
    params[:command]
  end

  def token
    params[:token]
  end
end
