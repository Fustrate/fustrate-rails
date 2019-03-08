class Fustrate.Components.Pagination extends Fustrate.Components.Base
  constructor: ({ @currentPage, @totalPages, @totalEntries, @perPage }) ->
    @base = @constructor._getPreppedPaginationURL()

  link: (text, page, options = {}) =>
    Fustrate.linkTo(text, "#{@base}page=#{page}", options)

  previousLink: =>
    if @currentPage > 1
      return "
        <li class=\"previous_page\">
          #{@link('← Previous', @currentPage - 1, rel: 'prev')}
        </li>"

    '<li class="previous_page unavailable"><a href="#">← Previous</a></li>'

  nextLink: =>
    if @currentPage < @totalPages
      return "
        <li class=\"next_page\">
          #{@link('Next →', @currentPage + 1, rel: 'next')}
        </li>"

    '<li class="next_page unavailable"><a href="#">Next →</a></li>'

  generate: =>
    pages = []

    if @totalPages > 1
      pages = for i in @windowedPageNumbers()
        if i is @currentPage
          "<li class=\"current\">#{Fustrate.linkTo(i, '#')}</li>"
        else if i is 'gap'
          '<li class="unavailable"><span class="gap">…</span></li>'
        else
          "<li>#{@link i, i}</li>"

      pages.unshift @previousLink()
      pages.push @nextLink()

    $('<ul class="pagination">').html pages.join(' ')

  windowedPageNumbers: =>
    window_from = @currentPage - 4
    window_to = @currentPage + 4

    if window_to > @totalPages
      window_from -= window_to - @totalPages
      window_to = @totalPages

    if window_from < 1
      window_to += 1 - window_from
      window_from = 1
      window_to = @totalPages if window_to > @totalPages

    middle = [window_from..window_to]

    left = if 4 < middle[0] then [1, 2, 'gap'] else [1...middle[0]]

    if @totalPages - 3 > middle.last()
      right = [(@totalPages - 1)..@totalPages]
      right.unshift 'gap'
    else if middle.last() + 1 <= @totalPages
      right = [(middle.last() + 1)..@totalPages]
    else
      right = []

    left.concat middle, right

  @getCurrentPage: ->
    window.location.search.match(/[?&]page=(\d+)/)?[1] ? 1

  # Just add 'page='
  @_getPreppedPaginationURL: ->
    search = window.location.search.replace(/[?&]page=\d+/, '')

    search = if search[0] is '?'
               "#{search}&"
             else if search[0] is '&'
               "?#{search[1...search.length]}&"
             else
               '?'

    "#{window.location.pathname}#{search}"
