class Startup < ApplicationRecord
  # You can add validations here as needed, for example:
  validates :name, :location, :description, :batch, :industry, :extended_description, presence: true
end
