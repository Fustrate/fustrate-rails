# frozen_string_literal: true

# Copyright (c) 2021 Steven Hoffman
# All rights reserved.

require 'active_support'
require_relative '../../config/initializers/sanitize'
require 'fustrate/rails/concerns/sanitize_html'
require 'sanitize'

SANITIZE_CONFIG = {
  elements: %w[p span],
  attributes: { 'p' => %w[style] }, # rubocop:disable Style/StringHashKeys
  transformers: [->(data) { ::Sanitize.clean_nodes(data[:node]) }],
  css: {
    allow_comments: false,
    allow_hacks: false,
    properties: %w[padding text-align padding-left]
  }
}.freeze

describe ::Fustrate::Rails::Concerns::SanitizeHtml do
  it 'baseline' do
    clean = described_class.sanitize(<<~HTML, ::SANITIZE_CONFIG)
      <p>Hello World</p>
    HTML

    expect(clean).to eq '<p>Hello World</p>'
  end

  it 'trims whitespace around paragraphs' do
    clean = described_class.sanitize(<<~HTML, ::SANITIZE_CONFIG)
      <p> Hello World </p>
    HTML

    expect(clean).to eq '<p>Hello World</p>'
  end

  it 'removes &nbsp;' do
    clean = described_class.sanitize(<<~HTML, ::SANITIZE_CONFIG)
      <p> Hello&nbsp;World&nbsp; </p>
    HTML

    expect(clean).to eq '<p>Hello World</p>'
  end

  it 'cleans the style attribute' do
    clean = described_class.sanitize(<<~HTML, ::SANITIZE_CONFIG)
      <p style=" padding: 0; text-align: left; padding-left: 30px;">
        Hello World
      </p>
    HTML

    expect(clean).to eq '<p style="padding-left: 30px;">Hello World</p>'
  end

  it 'normalizes quotes' do
    clean = described_class.sanitize(<<~HTML, ::SANITIZE_CONFIG)
      <p>‘Single Quotes’, “Double Quotes”</p>
    HTML

    expect(clean).to eq '<p>\'Single Quotes\', "Double Quotes"</p>'
  end

  it 'normalizes non-breaking spaces' do
    fragments = [
      "<p>Hello\u3000World</p>",
      "<p>Hello\u3000 World</p>",
      "<p>Hello\u00a0World</p>",
      "<p>Hello\u00a0 World</p>",
      '<p>Hello&nbsp;World</p>',
      '<p>Hello&nbsp; World</p>'
    ]

    fragments.each do |fragment|
      clean = described_class.sanitize(fragment, ::SANITIZE_CONFIG)

      expect(clean).to eq '<p>Hello World</p>'
    end
  end

  it 'puts newlines between root paragraphs' do
    fragments = [
      "<p>Hello</p>\n<p>World</p>",
      '<p>Hello</p> <p>World</p>'
    ]

    fragments.each do |fragment|
      clean = described_class.sanitize(fragment, ::SANITIZE_CONFIG)

      expect(clean).to eq "<p>Hello</p>\n<p>World</p>"
    end
  end
end
