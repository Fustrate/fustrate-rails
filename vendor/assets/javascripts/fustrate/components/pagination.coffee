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
      pages = for i in @windowedPageNumbers()
        if i == @current_page
          "<li class=\"current\">#{VMG.linkTo(i, '#')}</li>"
        else if i == 'gap'
          '<li class="unavailable"><span class="gap">…</span></li>'
        else
          "<li>#{@link i, i}</li>"

      pages.unshift @previousLink()
      pages.push @nextLink()

    $('<ul class="pagination">').html pages.join(' ')

  windowedPageNumbers: =>
    window_from = @current_page - 4
    window_to = @current_page + 4

    if window_to > @total_pages
      window_from -= window_to - @total_pages
      window_to = @total_pages

    if window_from < 1
      window_to += 1 - window_from
      window_from = 1
      window_to = @total_pages if window_to > @total_pages

    middle = [window_from..window_to]

    left = if 4 < middle[0] then [1, 2, 'gap'] else [1...middle[0]]

    if @total_pages - 3 > middle.last()
      right = [(@total_pages - 1)..@total_pages]
      right.unshift 'gap'
    else if middle.last() + 1 <= @total_pages
      right = [(middle.last() + 1)..@total_pages]
    else
      right = []

    left.concat middle, right

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
