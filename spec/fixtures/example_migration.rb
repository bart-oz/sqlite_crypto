# frozen_string_literal: true

class CreateExampleSchema < ActiveRecord::Migration[ActiveRecord::Migration.current_version]
  def change
    create_table :users, id: false do |t|
      t.uuid :id, primary_key: true
      t.string :email, null: false
      t.string :name
      t.timestamps
    end

    create_table :posts do |t|
      t.references :user
      t.string :title, null: false
      t.text :content
      t.timestamps
    end

    create_table :categories, id: false do |t|
      t.ulid :id, primary_key: true
      t.string :name, null: false
      t.timestamps
    end

    create_table :articles do |t|
      t.references :author, to_table: :users
      t.string :title
      t.timestamps
    end

    create_table :taggings do |t|
      t.references :post
      t.references :category
      t.timestamps
    end

    change_table :posts do |t|
      t.uuid :external_reference
    end
  end
end
