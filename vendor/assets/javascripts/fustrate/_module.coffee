#= require_self
#= require_directory .
#= require_tree .

class window.Fustrate
  @entityMap:
    '&': '&amp;'
    '<': '&lt;'
    '>': '&gt;'
    '"': '&quot;'
    "'": '&#39;'
    '/': '&#x2F;'
    '`': '&#x60;'
    '=': '&#x3D;'

  constructor: ->
    for own component of Fustrate.Components
      Fustrate.Components[component].initialize()

    @initialize()

    moment.updateLocale 'en',
      longDateFormat:
        LTS: 'h:mm:ss A'
        LT: 'h:mm A'
        L: 'M/D/YY'
        LL: 'MMMM D, YYYY'
        LLL: 'MMMM D, YYYY h:mm A'
        LLLL: 'dddd, MMMM D, YYYY h:mm A'
      calendar:
        lastDay: '[Yesterday at] LT'
        sameDay: '[Today at] LT'
        nextDay: '[Tomorrow at] LT'
        lastWeek: 'dddd [at] LT'
        nextWeek: '[next] dddd [at] LT'
        sameElse: 'L'

  initialize: ->
    # Loop through every element on the page with a data-js-class attribute
    # and convert the data attribute's value to a real object. Then instantiate
    # a new object of that class.
    $('[data-js-class]').each (index, elem) ->
      element = $(elem)
      klass = Fustrate._stringToClass element.data('js-class')

      element.data 'js-object', new klass(element)

    $.ajaxSetup
      cache: false
      beforeSend: $.rails.CSRFProtection

    $('table').wrap '<div class="responsive-table"></div>'

    $(window).resize @equalizeElements
    @equalizeElements()

    $('.number').each (index, elem) ->
      elem = $ @

      number = if elem.data('number') isnt undefined
        elem.data('number')
      else
        elem.html()

      elem.addClass 'negative' if parseInt(number, 10) < 0

  equalizeElements: ->
    $('[data-equalize]').each (i, container) ->
      filter = $(container).data('equalize')
      elements = $(filter, container).css(height: 'auto')

      maxHeight = Math.max.apply(
        null,
        ($(row).outerHeight() for row in elements)
      )

      elements.each (j, row) ->
        $(row).css(height: "#{maxHeight}px")

  # Take a string like 'Fustrate.Whiteboard.Entry' and retrieve the real class
  # with that name. Start at `window` and work down from there.
  @_stringToClass: (string) ->
    pieces = string.split('.')

    Fustrate._arrayToClass(pieces, window)

  @_arrayToClass: (pieces, root) ->
    return root[pieces[0]] if pieces.length is 1

    Fustrate._arrayToClass pieces.slice(1), root[pieces[0]]

  # Very similar to the Rails helper `link_to`. Returns an HTML string.
  @linkTo: (text, path, options = {}) ->
    $('<a>').prop('href', path).html(text).prop(options).outerHTML()

  @ajaxUpload: (url, data) ->
    formData = new FormData

    formData.append key, value for key, value of data

    $.ajax
      url: url
      type: 'POST'
      data: formData
      processData: false
      contentType: false
      dataType: 'script'
      beforeSend: (xhr) ->
        $.rails.CSRFProtection xhr

  @getCurrentPageJson: ->
    pathname = window.location.pathname.replace(/\/+$/, '')

    $.get "#{pathname}.json#{window.location.search}"

  @humanDate: (date, time = false) ->
    if date.year() is moment().year()
      date.format("M/D#{if time then ' h:mm A' else ''}")
    else
      date.format("M/D/YY#{if time then ' h:mm A' else ''}")

  @label: (text, type) ->
    css_classes = ['label', text.replace(/\s+/g, '-'), type].compact()

    $('<span>')
      .text(text)
      .prop('class', css_classes.join(' ').toLowerCase().dasherize())

  @icon: (types) ->
    classes = ("fa-#{type}" for type in types.split(' ')).join(' ')

    "<i class=\"fa #{classes}\"></i>"

  @escapeHtml: (string) ->
    return '' if string is null or string is undefined

    String(string).replace /[&<>"'`=\/]/g, (s) -> Fustrate.entityMap[s]

  @multilineEscapeHtml: (string) ->
    return '' if string is null or string is undefined

    String(string)
      .split(/\r?\n/)
      .map (line) -> Fustrate.escapeHtml(line)
      .join '<br />'

jQuery.fn.outerHTML = ->
  return '' unless @length

  return @[0].outerHTML if @[0].outerHTML

  $('<div>').append(@[0].clone()).remove().html()

moment.fn.toHumanDate = (time = false) ->
  year = if @year() isnt moment().year() then '/YY' else ''

  @format("M/D#{year}#{if time then ' h:mm A' else ''}")
