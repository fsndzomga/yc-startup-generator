# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# db/seeds.rb

# Path to the YAML file
# file_path = Rails.root.join('db', 'startups.yml')

# # Read the file
# yaml_content = File.read(file_path)

# # Remove the colons from the keys
# corrected_yaml_content = yaml_content.gsub(/:(\w+):/, '\1:')

# # Write the corrected content back to the file
# File.write(file_path, corrected_yaml_content)

# Read the raw content of the YAML file
raw_yaml = File.read(Rails.root.join('db', 'startups.yml'))

# Split the content into an array of startups, remove empty entries
startup_entries = raw_yaml.strip.split(/^---\s*$/).reject(&:empty?)

# Parse each startup entry and create database records
startup_entries.each do |entry|
  lines = entry.strip.split("\n").reject(&:empty?)
  startup_hash = {}
  current_key = nil

  lines.each do |line|
    if line.include?(':') && !line.strip.start_with?('-')
      key, value = line.split(':', 2).map(&:strip)
      current_key = key.to_sym
      startup_hash[current_key] = current_key == :industry ? [] : value
    elsif current_key && line.strip.start_with?('-')
      startup_hash[current_key] << line.strip[1..-1].strip
    elsif current_key
      startup_hash[current_key] += line.strip + ' '
    end
  end

  # Clean up any extra whitespace from multi-line strings
  startup_hash.each do |key, value|
    startup_hash[key] = value.strip if value.is_a?(String)
  end

  # Create the startup record
  Startup.create!(startup_hash)
end

puts "Created #{Startup.count} startups from the YAML file."
