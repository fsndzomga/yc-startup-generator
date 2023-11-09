class RemoveTagsFromStartups < ActiveRecord::Migration[7.0]
  def change
    remove_column :startups, :tags, :string
  end
end
