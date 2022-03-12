# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
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
  end
end

class Employee < ::ActiveRecord::Base
  include ::Fustrate::Rails::Concerns::CleanAttributes
end

describe ::Fustrate::Rails::Concerns::CleanAttributes do
  it 'nilifies blank strings' do
    employee = ::Employee.new(username: "\n\t ", email: ' ', website_bio: "\t\t\t")

    employee.validate

    expect(employee.username).to be_nil
    expect(employee.email).to be_nil
    expect(employee.website_bio).to be_nil
  end

  it 'strips non-blank strings' do
    employee = ::Employee.new(
      username: "  strip this text\n",
      email: "  strip this text\n",
      website_bio: "  strip this text\n"
    )

    employee.validate

    expect(employee.username).to eq 'strip this text'
    expect(employee.email).to eq 'strip this text'
    expect(employee.website_bio).to eq 'strip this text'
  end

  it 'removes trailing spaces on each line' do
    employee = ::Employee.new(
      username: "hello \nworld\t\n!",
      email: "hello \nworld\t\n!",
      website_bio: "hello \nworld\t\n!"
    )

    employee.validate

    expect(employee.username).to eq "hello\nworld\n!"
    expect(employee.email).to eq "hello\nworld\n!"
    expect(employee.website_bio).to eq "hello\nworld\n!"
  end

  it 'normalizes CRLF and CR to LF' do
    employee = ::Employee.new(
      username: "hello\r\nworld\r!",
      email: "hello\r\n world\r!",
      website_bio: "hello\r \nworld\r!"
    )

    employee.validate

    expect(employee.username).to eq "hello\nworld\n!"
    expect(employee.email).to eq "hello\nworld\n!"
    expect(employee.website_bio).to eq "hello\nworld\n!"
  end

  it 'removes excessive newlines' do
    employee = ::Employee.new(
      username: "hello\n\n\n\n\n\n\nworld!",
      email: "hello \n\n\n\n\n\n\nworld!",
      website_bio: "hello\n\n\n \n\n\n\nworld!"
    )

    employee.validate

    expect(employee.username).to eq "hello\n\nworld!"
    expect(employee.email).to eq "hello\n\nworld!"
    expect(employee.website_bio).to eq "hello\n\nworld!"
  end
end
