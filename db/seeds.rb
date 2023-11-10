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
require 'debug'

# Read the raw content of the YAML file
raw_yaml = File.read(Rails.root.join('db', 'startups.yml'))

# Split the content into an array of startups, remove empty entries
startup_entries = raw_yaml.strip.split(/^---\s*$/).reject(&:empty?)

def parse_startup_entries(startup_entries)
  startups = []

  startup_entries.each do |entry|
    startup_hash = parse_entry(entry)

    Startup.create!(startup_hash)
  end
end

def parse_entry(entry)
  lines = entry.strip.split("\n").reject(&:empty?)
  startup_hash = {}
  key = nil

  lines.each do |line|
    if new_section_started?(line, key)
      key = extract_key(line)
      startup_hash[key] = initial_value_for(key)
    end

    startup_hash[key] = parse_line(startup_hash[key], line, key) if key
  end

  startup_hash
end


def new_section_started?(line, current_key)
  line.include?(':') && !line.strip.start_with?('-') && current_key != :extended_description
end

def extract_key(line)
  line.split(':', 2).first.to_sym
end

def initial_value_for(key)
  key == :industry ? [] : ''
end

def parse_line(current_value, line, key)
  case key
  when :industry
    # Append industries to the array if the line starts with a dash
    current_value << extract_value(line, '-') if line.strip.start_with?('-')
  when :extended_description
    # For extended description, append the line, excluding the identifier
    current_value << " " unless current_value.empty? || line.start_with?("extended_description:")
    current_value << line.sub('extended_description:', '').strip
  else
    # For other keys, assign the value if it's on the same line or append if it's a continuation
    if line.start_with?("#{key}:")
      # Assign the value if it's on the same line as the key
      current_value = extract_value(line)
    elsif !current_value.empty?
      # Append if it's a continuation of the previous value
      current_value << " #{line.strip}"
    end
  end
  current_value
end


def extract_value(line, delimiter = ':')
  # debugger
  line.split(delimiter, 2).last.strip
end

# The method call to start the process would be something like this:
parse_startup_entries(startup_entries)

puts "Created #{Startup.count} startups from the YAML file."
