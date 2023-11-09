class CreateStartups < ActiveRecord::Migration[7.0]
  def change
    create_table :startups do |t|
      t.string :name
      t.string :location
      t.string :description
      t.string :batch
      t.text :industry, array: true, default: []  # Changed to text with array: true
      t.string :tags
      t.text :extended_description

      t.timestamps
    end

    # Optionally, add a GIN index for better performance on queries involving the array
    add_index :startups, :industry, using: 'gin'
  end
end
