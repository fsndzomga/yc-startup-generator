# app/controllers/ideas_controller.rb
class IdeasController < ApplicationController

  def create
    @industry = params[:idea][:industry] if params[:idea][:industry]
    @location = params[:idea][:location] if params[:idea][:location]

    if @location.nil?
      @location = []
    end

    @industry.shift
    @location.shift

    idea_generator_service = IdeaGeneratorService.new(@industry, @location)
    idea_data = idea_generator_service.generate

    @idea = Idea.new(idea_params.merge(idea_data))
    if @idea.save
      # Redirect to the show page of the created idea
      redirect_to idea_path(@idea)
    else
      render json: { errors: @idea.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @idea = Idea.find(params[:id])
  end

  private

  def idea_params
    # Update permitted parameters according to your updated schema
    params.require(:idea).permit(:name, :industry, :description)
  end
end
