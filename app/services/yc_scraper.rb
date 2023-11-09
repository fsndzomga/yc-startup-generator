require 'nokogiri'
require 'selenium-webdriver'
require 'webdrivers'
require 'yaml'

chromedriver_path = '/Users/fsndzomga/Downloads/chromedriver-mac-arm64/chromedriver'
Selenium::WebDriver::Chrome::Service.driver_path = chromedriver_path


class YcScraper
  YC_BASE_URL = 'https://www.ycombinator.com'
  YC_COMPANIES_PATH = '/companies'

  def self.setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')

    options.add_argument('--no-sandbox') # This disables the sandbox for the ChromeDriver session
    options.add_argument('--disable-dev-shm-usage') # This forces Chrome to use the /tmp directory for shared memory

    Selenium::WebDriver.for(:chrome, options: options)
  end

  def self.scroll_to_load_all_content(driver)
    last_height = driver.execute_script("return document.body.scrollHeight")
    no_new_content_loads = 0 # Counter to keep track of consecutive failed content loads

    loop do
      # Scroll down to the bottom and wait for the page to load
      driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
      sleep 5 # Increase if necessary

      # Check if there are any indicators that no more content is available
      break if driver.execute_script("return document.body.innerText").include?("No more content")

      new_height = driver.execute_script("return document.body.scrollHeight")
      if new_height == last_height
        no_new_content_loads += 1
        # Try reloading 3 times before breaking the loop, in case it's a temporary issue
        break if no_new_content_loads >= 3
      else
        # Reset the counter if new content is loaded
        no_new_content_loads = 0
      end

      # Update the last_height to the new height for the next iteration
      last_height = new_height
    end
  end

  def self.scrape_startups
    counter = 0
    driver = setup_driver
    driver.navigate.to(YC_BASE_URL + YC_COMPANIES_PATH)

    # Use the refactored scrolling method to ensure all content is loaded
    scroll_to_load_all_content(driver)

    # Parse the page with Nokogiri after scrolling
    doc = Nokogiri::HTML(driver.page_source)

    # Initialize an empty array to hold startup data
    startups = []

    doc.css('._company_lx3q7_339').each do |startup_div|
      name = startup_div.at_css('._coName_lx3q7_454')&.text&.strip || 'N/A'
      location = startup_div.at_css('._coLocation_lx3q7_470')&.text&.strip || 'N/A'
      description = startup_div.at_css('._coDescription_lx3q7_479')&.text&.strip || 'N/A'

      batch_element = startup_div.at_css('.fa-y-combinator')
      batch = batch_element ? batch_element.parent.text.strip : 'N/A'

      industry_elements = startup_div.css('._tagLink_lx3q7_1013 .pill')

      if batch == 'N/A'
        industry = industry_elements.any? ? industry_elements.map(&:text) : []
      else
        industry = industry_elements.any? ? industry_elements.map(&:text).drop(1) : []
      end


      # Get the outermost a tag href attribute for the startup
      profile_url = startup_div[:href] ? YC_BASE_URL + startup_div[:href] : nil

      extended_description = profile_url ? scrape_extended_description(driver, profile_url) : 'N/A'

      puts "Name: #{name}"
      puts "Location: #{location}"
      puts "Description: #{description}"
      puts "Batch: #{batch}"
      puts "Industry: #{industry}"
      puts "Extended Description: #{extended_description}"
      puts "-----------------------------------"

      # Add the startup hash to the startups array
      startup_data = {
        name: name,
        location: location,
        description: description,
        batch: batch,
        industry: industry,
        extended_description: extended_description
      }
      startups << startup_data

      # Write the current state of startups array to the YAML file
      File.open("startups.yml", "a") { |file| file.write(startup_data.to_yaml) }

      counter += 1
    end

    driver.quit # Make sure to quit the driver to free resources
    puts "Total startups scraped: #{counter}"
  end

  def self.scrape_extended_description(driver, profile_url)
    driver.navigate.to(profile_url)
    sleep 2 # Wait to load page
    profile_doc = Nokogiri::HTML(driver.page_source)
    # Return the text or nil if not found
    profile_doc.at_css('div.prose p')&.text&.strip
  rescue OpenURI::HTTPError => e
    puts "Failed to open #{profile_url}: #{e}"
    nil
  end
end
