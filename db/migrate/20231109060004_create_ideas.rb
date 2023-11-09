class CreateIdeas < ActiveRecord::Migration[7.0]
  def change
    create_table :ideas do |t|
      t.string :industry
      t.string :tags
      t.string :location

      t.timestamps
    end
  end
end
