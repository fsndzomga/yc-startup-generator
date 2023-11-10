# app/services/idea_generator_service.rb
class IdeaGeneratorService
  def initialize(industry, location)
    @industry = industry
    @location = location
  end

  def generate
    # Here you would implement the logic to generate an idea based on the industry and location.
    "A revolutionary new #{ @industry } startup based in #{ @location }."
  end
end
