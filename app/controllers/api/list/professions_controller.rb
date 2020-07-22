class Api::List::ProfessionsController < ApplicationController
  def index
    render json: Profession.all
  end
end
