class Api::ApplicationController < ApplicationController
  rescue_from BadError, with: :handle_400
  rescue_from AuthenticationError, with: :handle_401
  rescue_from JWT::VerificationError, with: :handle_401
  rescue_from JWT::ExpiredSignature, with: :handle_401
  rescue_from JWT::DecodeError, with: :handle_401
  rescue_from ActiveRecord::RecordNotFound, with: :handle_404

  def handle_400(exception)
    render json: { success: false, error: exception.message }, status: :bad_request
  end

  def handle_401(exception)
    render json: { success: false, error: exception.message }, status: :unauthorized
  end

  def handle_404
    render json: { success: false, error: "Record not found" }, status: :not_found
  end
end
