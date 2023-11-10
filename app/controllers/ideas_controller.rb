# app/controllers/ideas_controller.rb
class IdeasController < ApplicationController
  def create
    @idea = Idea.new(idea_params)
    if @idea.save
      # Here you can call a method to generate an idea based on the industry and location
      generated_idea = IdeaGeneratorService.new(@idea.industry, @idea.location).generate
      puts generated_idea
      render json: { idea: generated_idea }
    else
      render json: { errors: @idea.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def idea_params
    params.require(:idea).permit(industry: [], :location)
  end
end
