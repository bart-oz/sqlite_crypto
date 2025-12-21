# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Migration Helpers" do
  let(:connection) { ActiveRecord::Base.connection }

  after do
    [:users, :posts, :comments, :tags].each { |t| connection.drop_table t, if_exists: true }
  end

  describe "TableDefinition DSL methods" do
    it "creates uuid and ulid columns with proper types" do
      connection.create_table :users do |t|
        t.uuid :external_id, null: false
        t.ulid :tracking_id
      end

      external_col = connection.columns(:users).find { |c| c.name == "external_id" }
      tracking_col = connection.columns(:users).find { |c| c.name == "tracking_id" }

      expect(external_col.sql_type).to eq("varchar(36)")
      expect(external_col.limit).to eq(36)
      expect(external_col.null).to be false
      expect(tracking_col.sql_type).to eq("varchar(26)")
      expect(tracking_col.limit).to eq(26)
      expect(tracking_col.null).to be true
    end

    it "works in change_table blocks" do
      connection.create_table :users
      connection.change_table :users do |t|
        t.uuid :external_id
        t.ulid :tracking_id
      end

      expect(connection.columns(:users).find { |c| c.name == "external_id" }.sql_type).to eq("varchar(36)")
      expect(connection.columns(:users).find { |c| c.name == "tracking_id" }.sql_type).to eq("varchar(26)")
    end
  end

  describe "References auto-detection" do
    context "with UUID primary keys" do
      before do
        connection.create_table :users, id: false do |t|
          t.uuid :id, primary_key: true
        end
      end

      it "auto-detects UUID and creates varchar(36) foreign keys" do
        connection.create_table :posts do |t|
          t.references :user
          t.belongs_to :author, to_table: :users
        end

        user_id_col = connection.columns(:posts).find { |c| c.name == "user_id" }
        author_id_col = connection.columns(:posts).find { |c| c.name == "author_id" }

        expect(user_id_col.sql_type).to eq("varchar(36)")
        expect(author_id_col.sql_type).to eq("varchar(36)")
      end

      it "allows explicit type override" do
        connection.create_table :posts do |t|
          t.references :user, type: :integer
        end

        expect(connection.columns(:posts).find { |c| c.name == "user_id" }.sql_type).to match(/integer/i)
      end

      it "works in change_table blocks" do
        connection.create_table :posts
        connection.change_table(:posts) { |t| t.references :user }

        expect(connection.columns(:posts).find { |c| c.name == "user_id" }.sql_type).to eq("varchar(36)")
      end
    end

    context "with ULID primary keys" do
      before do
        connection.create_table :tags, id: false do |t|
          t.ulid :id, primary_key: true
        end
      end

      it "auto-detects ULID and creates varchar(26) foreign keys" do
        connection.create_table :posts do |t|
          t.references :tag
          t.references :label, to_table: :tags
        end

        expect(connection.columns(:posts).find { |c| c.name == "tag_id" }.sql_type).to eq("varchar(26)")
        expect(connection.columns(:posts).find { |c| c.name == "label_id" }.sql_type).to eq("varchar(26)")
      end
    end

    context "with standard integer primary keys" do
      before { connection.create_table :users }

      it "uses default INTEGER type" do
        connection.create_table :posts do |t|
          t.references :user
        end

        expect(connection.columns(:posts).find { |c| c.name == "user_id" }.sql_type).to eq("INTEGER")
      end
    end

    context "with non-existent tables" do
      it "falls back to INTEGER" do
        connection.create_table :posts do |t|
          t.references :missing_thing
        end

        expect(connection.columns(:posts).find { |c| c.name == "missing_thing_id" }.sql_type).to eq("INTEGER")
      end
    end

    it "handles mixed reference types in the same table" do
      connection.create_table :users, id: false do |t|
        t.uuid :id, primary_key: true
      end
      connection.create_table :tags, id: false do |t|
        t.ulid :id, primary_key: true
      end

      connection.create_table :posts do |t|
        t.references :user
        t.references :tag
        t.integer :view_count
      end

      expect(connection.columns(:posts).find { |c| c.name == "user_id" }.sql_type).to eq("varchar(36)")
      expect(connection.columns(:posts).find { |c| c.name == "tag_id" }.sql_type).to eq("varchar(26)")
      expect(connection.columns(:posts).find { |c| c.name == "view_count" }.sql_type).to eq("INTEGER")
    end

    it "handles polymorphic associations" do
      connection.create_table :comments do |t|
        t.references :commentable, polymorphic: true
      end

      expect(connection.columns(:comments).find { |c| c.name == "commentable_type" }.sql_type).to eq("varchar")
      expect(connection.columns(:comments).find { |c| c.name == "commentable_id" }.sql_type).to eq("INTEGER")
    end
  end

  describe "Integration" do
    it "creates proper schema with auto-detected UUID foreign keys" do
      connection.create_table :users, id: false do |t|
        t.uuid :id, primary_key: true
        t.string :name
      end

      connection.create_table :posts do |t|
        t.references :user
        t.string :title
      end

      user_id_col = connection.columns(:posts).find { |c| c.name == "user_id" }
      expect(user_id_col.sql_type).to eq("varchar(36)")

      user_id = "550e8400-e29b-41d4-a716-446655440000"
      connection.execute("INSERT INTO users (id, name) VALUES ('#{user_id}', 'Test')")
      connection.execute("INSERT INTO posts (user_id, title) VALUES ('#{user_id}', 'Post')")

      post = connection.select_one("SELECT * FROM posts WHERE title = 'Post'")
      expect(post["user_id"]).to eq(user_id)
    end
  end
end
