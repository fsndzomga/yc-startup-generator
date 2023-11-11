class ModifyIdeas < ActiveRecord::Migration[7.0]
  def change
    remove_column :ideas, :location
    add_column :ideas, :name, :string
    add_column :ideas, :description, :text
  end
end
