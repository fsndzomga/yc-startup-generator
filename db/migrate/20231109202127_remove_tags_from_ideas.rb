class RemoveTagsFromIdeas < ActiveRecord::Migration[7.0]
  def change
    remove_column :ideas, :tags, :string
  end
end
