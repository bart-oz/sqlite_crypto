# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Auto ID Generation Integration" do
  let(:connection) { ActiveRecord::Base.connection }

  after do
    [:comments, :posts, :authors].each do |table|
      connection.drop_table table, if_exists: true
    end
  end

  describe "zero-config UUID workflow" do
    before do
      connection.create_table :authors, id: :uuid, force: true do |t|
        t.string :name
        t.timestamps
      end

      stub_const("Author", Class.new(ActiveRecord::Base) do
        self.table_name = "authors"
      end)
    end

    it "creates records with auto-generated UUIDs without any model config" do
      author = Author.create!(name: "Jane Doe")

      expect(author.id).to be_present
      expect(author.id).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)

      reloaded = Author.find(author.id)
      expect(reloaded.name).to eq("Jane Doe")
    end

    it "supports multiple record creation" do
      authors = 5.times.map { |i| Author.create!(name: "Author #{i}") }
      ids = authors.map(&:id)

      expect(ids.uniq.size).to eq(5)
      ids.each do |id|
        expect(id).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      end
    end
  end

  describe "zero-config ULID workflow" do
    before do
      connection.create_table :posts, id: :ulid, force: true do |t|
        t.string :title
        t.timestamps
      end

      stub_const("Post", Class.new(ActiveRecord::Base) do
        self.table_name = "posts"
      end)
    end

    it "creates records with auto-generated ULIDs without any model config" do
      post = Post.create!(title: "Hello World")

      expect(post.id).to be_present
      expect(post.id).to match(/\A[0-9A-Z]{26}\z/)

      reloaded = Post.find(post.id)
      expect(reloaded.title).to eq("Hello World")
    end
  end

  describe "UUID with foreign keys" do
    before do
      connection.create_table :authors, id: :uuid, force: true do |t|
        t.string :name
        t.timestamps
      end

      connection.create_table :posts, id: :uuid, force: true do |t|
        t.references :author, type: :string, limit: 36
        t.string :title
        t.timestamps
      end

      stub_const("Author", Class.new(ActiveRecord::Base) do
        self.table_name = "authors"
        has_many :posts
      end)

      stub_const("Post", Class.new(ActiveRecord::Base) do
        self.table_name = "posts"
        belongs_to :author
      end)
    end

    it "works end-to-end with associations" do
      author = Author.create!(name: "Jane")
      post = Post.create!(title: "Test", author: author)

      expect(author.id).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(post.id).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(post.author_id).to eq(author.id)
      expect(author.posts).to include(post)
    end
  end

  describe "generates_uuid for non-PK columns alongside auto-generation" do
    before do
      connection.create_table :authors, id: :uuid, force: true do |t|
        t.string :name
        t.string :api_token, limit: 36
        t.timestamps
      end

      stub_const("Author", Class.new(ActiveRecord::Base) do
        self.table_name = "authors"
        generates_uuid :api_token
      end)
    end

    it "auto-generates both PK and non-PK UUIDs" do
      author = Author.create!(name: "Jane")

      expect(author.id).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(author.api_token).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(author.id).not_to eq(author.api_token)
    end
  end

  describe "mixed ID types in same app" do
    before do
      connection.create_table :authors, id: :uuid, force: true do |t|
        t.string :name
      end

      connection.create_table :comments, force: true do |t|
        t.string :body
      end

      stub_const("Author", Class.new(ActiveRecord::Base) do
        self.table_name = "authors"
      end)

      stub_const("Comment", Class.new(ActiveRecord::Base) do
        self.table_name = "comments"
      end)
    end

    it "generates UUIDs for UUID tables and integers for integer tables" do
      author = Author.create!(name: "Jane")
      comment = Comment.create!(body: "Nice!")

      expect(author.id).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
      expect(comment.id).to be_a(Integer)
    end
  end
end
