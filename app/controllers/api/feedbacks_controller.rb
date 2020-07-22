class Api::FeedbacksController < Api::User::ApplicationController

  include MergeImageParam

  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.save
      add_or_remove_image_related_model(@feedback.image_feedbacks, params[:images])
      render json: @feedback, status: :created
    else
      render json: @feedback.errors, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.permit(:email, :description, :user_id).merge({ user_id: current_user.id })
  end

end
