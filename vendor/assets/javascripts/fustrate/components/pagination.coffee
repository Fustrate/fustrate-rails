class Fustrate.Components.Pagination extends Fustrate.Components.Base
  constructor: ({@current_page, @total_pages, @total_entries, @per_page}) ->
    @base = @constructor._getPreppedPaginationURL()

  link: (text, page, options = {}) =>
    Fustrate.linkTo(text, "#{@base}page=#{page}", options)

  previousLink: =>
    if @current_page > 1
      return "
        <li class=\"previous_page\">
          #{@link('← Previous', @current_page - 1, rel: 'prev')}
        </li>"

    '<li class="previous_page unavailable"><a href="#">← Previous</a></li>'

  nextLink: =>
    if @current_page < @total_pages
      return "
        <li class=\"next_page\">
          #{@link('Next →', @current_page + 1, rel: 'next')}
        </li>"

    '<li class="next_page unavailable"><a href="#">Next →</a></li>'

  generate: =>
    pages = []

    if @total_pages > 1
      for i in [1..@total_pages]
        if i == @current_page
          pages.push "<li class=\"current\">#{VMG.linkTo(i, '#')}</li>"
        else
          pages.push "<li>#{@link i, i}</li>"

      pages.unshift @previousLink()
      pages.push @nextLink()

    $('<ul class="pagination">').html(pages.join ' ')

  @getCurrentPage: ->
    window.location.search.match(/[?&]page=(\d+)/)?[1] ? 1

  # Just add 'page='
  @_getPreppedPaginationURL: ->
    search = window.location.search.replace(/[?&]page=\d+/, '')

    search = if search[0] == '?'
               "#{search}&"
             else if search[0] == '&'
               "?#{search[1...search.length]}&"
             else
               '?'

    "#{window.location.pathname}#{search}"
