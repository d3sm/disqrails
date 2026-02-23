class AddArticleMetadataToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :source_image_url, :string
    add_column :posts, :source_description, :text
  end
end
