class Api::List::ProfessionsController < ApiApplicationController
  def index
    render json: Profession.all
  end
end
