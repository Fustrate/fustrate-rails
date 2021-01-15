# frozen_string_literal: true

# Copyright (c) 2020 Steven Hoffman
# All rights reserved.

class Sanitize
  class CSS
    def properties(css)
      tree = ::Crass.parse_properties(
        css,
        preserve_comments: @config[:allow_comments],
        preserve_hacks: @config[:allow_hacks]
      )

      tree!(tree)

      ::CSSTreeStringifier.new.stringify(tree)
    end
  end

  SELF_CLOSING = %w[br td img hr input].freeze

  def self.clean_nodes(node)
    # Replace non-root empty nodes with a blank space
    return node.replace(' ') if empty_element?(node)

    # Replace root empty nodes with a newline
    if node.text? && !node.parent&.parent && node.text.blank?
      # Replacing a newline with a newline causes an infinite loop
      return node.text == "\n" ? node : node.replace("\n")
    end

    clean_style_attribute(node)
    clean_attributes(node)
    clean_whitespace(node)
  end

  # Remove useless padding and text-align attributes
  def self.clean_style_attribute(node)
    return unless node['style']

    style = node['style']
      .gsub(/padding: 0(?:px|rem|in|em|);/, '')
      .gsub(/text-align: (?:start|justify|left);/, '')
      .strip

    if style.present?
      node['style'] = style
    else
      node.remove_attribute 'style'
    end
  end

  # Remove empty attributes from a node, e.g. alt=""
  def self.clean_attributes(node)
    return unless node.element?

    node.attributes.each do |key, value|
      node.remove_attribute(key) if value.text.empty?
    end
  end

  def self.clean_whitespace(node)
    if node.text?
      node.content = node.content.gsub(/[[:space:]]+/, ' ')
    elsif node.element?
      clean_element_whitespace(node)
    end
  end

  def self.clean_element_whitespace(node)
    if node.name.casecmp('p').zero?
      clean_paragraph_tag(node.children.first, true)
      clean_paragraph_tag(node.children.last, false)
    else
      node
    end
  end

  def self.clean_paragraph_tag(node, is_first)
    return unless node&.text?

    return node.content = '' if node.text.blank?

    # Remove all leading whitespace and replace all space-like chars with a single space
    node.content = node.content
      .gsub(is_first ? /\A[[:space:]]+/ : /[[:space:]]+\z/, '')
      .gsub(/[[:space:]]+/, ' ')
  end

  def self.clean_page_breaks(node)
    return unless node.element?

    if node.content.match?(/↡/)
      node.content = '↡'
      node['class'] = 'pagebreak'
      node.remove_attribute 'style'
    elsif node['class']
      node.remove_attribute 'class'
    end
  end

  def self.empty_element?(node)
    node.element? && !self_closing?(node) && !content?(node)
  end

  def self.content?(node)
    return true if text?(node)

    if node.element?
      node.children.each do |child|
        return true if content_or_self_closing?(child)
      end
    end

    false
  end

  def self.content_or_self_closing?(node)
    self_closing?(node) || text?(node) || content?(node)
  end

  def self.self_closing?(node)
    self::SELF_CLOSING.include?(node.name.downcase)
  end

  def self.text?(node)
    node.text? && node.text.present?
  end
end
