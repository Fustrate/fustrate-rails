# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

require 'active_record'
require 'active_support'
require 'fustrate/rails/concerns/clean_attributes'

::ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
::ActiveRecord::Base.logger = ::Logger.new($stdout)

::ActiveRecord::Schema.define do
  create_table :employees, force: true do |t|
    t.string :username
    t.text :website_bio
    # SQLite doesn't have a citext type... not sure how to test that specific part.
    t.string :email
    # SQLite also doesn't have an array type...
    t.string :aliases
  end
end

class Employee < ::ActiveRecord::Base
  include ::Fustrate::Rails::Concerns::CleanAttributes

  serialize :aliases

  after_initialize do |employee|
    employee.aliases = [] if employee.aliases.nil?
  end
end

describe ::Fustrate::Rails::Concerns::CleanAttributes do
  it 'nilifies blank strings' do
    employee = ::Employee.new(username: "\n\t ", email: ' ', website_bio: "\t\t\t")

    employee.validate

    expect(employee).to have_attributes(username: nil, email: nil, website_bio: nil)
  end

  it 'strips non-blank strings' do
    employee = ::Employee.new(
      username: "  strip this text\n",
      email: "  strip this text\n",
      website_bio: "  strip this text\n"
    )

    employee.validate

    expect(employee)
      .to have_attributes(username: 'strip this text', email: 'strip this text', website_bio: 'strip this text')
  end

  # This doesn't work with SQLite, I need to run these tests on postgres
  xit 'strips an array of strings' do
    employee = ::Employee.new(username: "\n\t ", email: ' ', website_bio: "\t\t\t", aliases: [' dave', 'd dawg '])

    employee.validate

    expect(employee).to have_attributes(username: nil, email: nil, website_bio: nil, aliases: ['dave', 'd dawg'])
  end

  it 'removes trailing spaces on each line' do
    employee = ::Employee.new(
      username: "hello \nworld\t\n!",
      email: "hello \nworld\t\n!",
      website_bio: "hello \nworld\t\n!"
    )

    employee.validate

    expect(employee)
      .to have_attributes(username: "hello\nworld\n!", email: "hello\nworld\n!", website_bio: "hello\nworld\n!")
  end

  it 'normalizes CRLF and CR to LF' do
    employee = ::Employee.new(
      username: "hello\r\nworld\r!",
      email: "hello\r\n world\r!",
      website_bio: "hello\r \nworld\r!"
    )

    employee.validate

    expect(employee)
      .to have_attributes(username: "hello\nworld\n!", email: "hello\nworld\n!", website_bio: "hello\nworld\n!")
  end

  it 'removes excessive newlines' do
    employee = ::Employee.new(
      username: "hello\n\n\n\n\n\n\nworld!",
      email: "hello \n\n\n\n\n\n\nworld!",
      website_bio: "hello\n\n\n \n\n\n\nworld!"
    )

    employee.validate

    expect(employee)
      .to have_attributes(username: "hello\n\nworld!", email: "hello\n\nworld!", website_bio: "hello\n\nworld!")
  end
end
