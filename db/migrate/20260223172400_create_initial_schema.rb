class CreateInitialSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :url
      t.text :text
      t.string :source, null: false, default: "local"
      t.bigint :external_id
      t.integer :hn_score
      t.integer :hn_descendants
      t.string :hn_by
      t.string :hn_type
      t.integer :hn_rank

      t.timestamps
    end
    add_index :posts, :created_at
    add_index :posts, :hn_rank
    add_index :posts, :hn_type
    add_index :posts, :external_id, unique: true, where: "external_id IS NOT NULL"
  end
end
