# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run Ruby linter"
task :lint do
  sh "bundle exec standardrb --format progress"
end

task "lint:fix" do
  sh "bundle exec standardrb --fix --format progress"
end
