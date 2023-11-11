require 'dotenv'
require 'ruby/openai'

Dotenv.load

class IdeaGeneratorService
  def initialize(industry, location)
    @industry = industry
    @location = location
  end

  def generate
    startups = fetch_startups
    return "No startups found." if startups.empty?

    startups_info = startups.map do |startup|
      "Name: #{startup.name}, Industry: #{startup.industry}, Description: #{startup.description}"
    end.join("\n")

    idea_prompt = "Generate a startup idea based on these startups:\n#{startups_info}. Keep it under 100 characters. Always provide your response using markdown. Make it beautiful. For example like this: '# Idea Name: DataDetect

    ## Industry
    - B2B
    - Analytics

    ## Description
    **Instant data insights, no SQL needed.**

    DataDetect is a B2B analytics platform that allows businesses to easily and quickly analyze their data without the need to write complex SQL queries. Our intuitive interface and advanced algorithms provide actionable insights, helping businesses make informed decisions and optimize their operations. With DataDetect, you can uncover valuable information from your data with just a few clicks, saving time and resources.
    '"
    description = generate_idea_with_openai(idea_prompt)

    {
      name: " ",
      industry: @industry,
      description: description
    }
  end

  private

  def fetch_startups
    industry_array = @industry.map(&:to_s)
    industry_filtered_startups = Startup.where('industry && ARRAY[?]::text[]', industry_array)

    combined_location_query = nil
    if @location.present?
      @location.each do |location|
        location_query = Startup.where(location: location)
        combined_location_query = combined_location_query ? combined_location_query.or(location_query) : location_query
      end

      industry_filtered_startups = industry_filtered_startups.or(combined_location_query) if combined_location_query
    end

    # Shuffle the results and then limit
    industry_filtered_startups.order('RANDOM()').limit(10)
  end

  def generate_idea_with_openai(prompt)
    if ENV['OPENAI_API_KEY']
      llm = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

      response = llm.chat(
        parameters: {
          model: "gpt-3.5-turbo-1106",
          messages: [{ role: "system", content: prompt }]
        }
      )

      return response.dig("choices", 0, "message", "content")
    else
      Rails.logger.error "Set the OPENAI_API_KEY in the ENV variables"
      "Error: OPENAI_API_KEY not set."
    end
  end
end
