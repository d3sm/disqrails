class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.bigint :external_id, null: false
      t.bigint :parent_external_id
      t.integer :depth, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.string :author
      t.text :body_html
      t.datetime :posted_at
      t.boolean :hn_deleted, null: false, default: false
      t.boolean :hn_dead, null: false, default: false

      t.timestamps
    end

    add_index :comments, :external_id, unique: true
    add_index :comments, [ :post_id, :position ]
    add_index :comments, [ :post_id, :parent_external_id ]
  end
end
