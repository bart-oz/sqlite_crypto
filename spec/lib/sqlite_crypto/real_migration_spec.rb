# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Real Migration Example" do
  let(:connection) { ActiveRecord::Base.connection }
  let(:migration_class) {
    load File.expand_path("../../fixtures/example_migration.rb", __dir__)
    CreateExampleSchema
  }

  after do
    [:taggings, :articles, :categories, :posts, :users].each do |table|
      connection.drop_table table, if_exists: true
    end
  end

  it "successfully runs a real migration with uuid/ulid helpers" do
    migration = migration_class.new

    expect { migration.migrate(:up) }.not_to raise_error

    users_id = connection.columns(:users).find { |c| c.name == "id" }
    expect(users_id.sql_type).to eq("uuid")

    categories_id = connection.columns(:categories).find { |c| c.name == "id" }
    expect(categories_id.sql_type).to eq("ulid")

    posts_user_id = connection.columns(:posts).find { |c| c.name == "user_id" }
    expect(posts_user_id.sql_type).to eq("varchar(36)")

    articles_author_id = connection.columns(:articles).find { |c| c.name == "author_id" }
    expect(articles_author_id.sql_type).to eq("varchar(36)")

    taggings_category_id = connection.columns(:taggings).find { |c| c.name == "category_id" }
    expect(taggings_category_id.sql_type).to eq("varchar(26)")

    taggings_post_id = connection.columns(:taggings).find { |c| c.name == "post_id" }
    expect(taggings_post_id.sql_type).to eq("INTEGER")

    posts_external_ref = connection.columns(:posts).find { |c| c.name == "external_reference" }
    expect(posts_external_ref.sql_type).to eq("uuid")
  end

  it "allows inserting real data with UUID/ULID types" do
    migration = migration_class.new
    migration.migrate(:up)

    user_id = "550e8400-e29b-41d4-a716-446655440000"
    category_id = "01ARZ3NDEKTSV4RRFFQ69G5FAV"
    now = Time.now.utc.iso8601

    connection.execute("INSERT INTO users (id, email, name, created_at, updated_at) VALUES ('#{user_id}', 'test@example.com', 'Test User', '#{now}', '#{now}')")
    connection.execute("INSERT INTO categories (id, name, created_at, updated_at) VALUES ('#{category_id}', 'Tech', '#{now}', '#{now}')")
    connection.execute("INSERT INTO posts (user_id, title, content, created_at, updated_at) VALUES ('#{user_id}', 'Hello', 'World', '#{now}', '#{now}')")

    user = connection.select_one("SELECT * FROM users WHERE id = '#{user_id}'")
    expect(user["email"]).to eq("test@example.com")

    post = connection.select_one("SELECT * FROM posts WHERE title = 'Hello'")
    expect(post["user_id"]).to eq(user_id)
  end
end
