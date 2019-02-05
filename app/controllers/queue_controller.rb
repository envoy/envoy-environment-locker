class QueueController < ApplicationController
  skip_before_action :verify_authenticity_token

  def perform_action
    render json: QueueManager.new(user_id).perform(command)
  end

  private

  def user_id
    params[:user_id]
  end

  def command
    params[:command]
  end
end
