#= require_self
#= require_directory .
#= require_tree .

class window.Fustrate
  @VERSION: '0.4.1.1'
  @libs: {}

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
    lib.init() for own name, lib of @constructor.libs

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

# Replicate a few common prototype methods on String and Array
String::titleize = ->
  @replace(/_/g, ' ').replace /\b[a-z]/g, (char) -> char.toUpperCase()

String::capitalize = ->
  @charAt(0).toUpperCase() + @slice(1)

String::phoneFormat = ->
  if /^(\d+)(ext|x)(\d+)$/.test @
    @replace /(\d+)(ext|x)(\d+)/, ->
      arguments[1].phoneFormat() + ' x' + arguments[3]
  else if /^1\d{10}$/.test @
    @replace /1(\d{3})(\d{3})(\d{4})/, '1 ($1) $2-$3'
  else if /^\d{10}$/.test @
    @replace /(\d{3})(\d{3})(\d{4})/, '($1) $2-$3'
  else if /^\d{7}$/.test @
    @replace /(\d{3})(\d{4})/, '$1-$2'
  else
    @

String::dasherize = ->
  @replace /_/g, '-'

Array::compact = (strings = true) ->
  @forEach (element, index) =>
    @splice(index, 1) if element is undefined or (strings and element is '')

  @

Array::toSentence = ->
  switch @length
    when 0 then ''
    when 1 then @[0]
    when 2 then "#{@[0]} and #{@[1]}"
    else "#{@slice(0, -1).join(', ')}, and #{@[@length - 1]}"

Array::remove = (object) ->
  index = @indexOf object
  @splice index, 1 if index isnt -1

Array::first = ->
  @[0]

Array::last = ->
  @[@length - 1]

Array::peek = Array::last

# Used to define getters and setters
Function::define = (name, methods) ->
  Object.defineProperty @::, name, methods

Function::debounce = (delay = 250) ->
  timeout = null
  self = @

  (args...) ->
    context = @

    delayedFunc = ->
      self.apply(context, args)
      timeout = null

    clearTimeout(timeout) if timeout

    timeout = setTimeout delayedFunc, delay

Object.defineProperty Object.prototype, 'tap',
  enumerable: false
  value: (func) ->
    if typeof func is 'function'
      func.apply(@)
    else
      @[func].apply(@, Array::slice.call(arguments).slice(1))

    @

Number::bytesToString = ->
  return "#{@} B" if @ < 1000

  return "#{(@ / 1000).toFixed(2).replace(/[0.]+$/, '')} kB" if @ < 1000000

  if @ < 1000000000
    return "#{(@ / 1000000).toFixed(2).replace(/[0.]+$/, '')} MB"

  "#{(@ / 1000000000).toFixed(2).replace(/[0.]+$/, '')} GB"

String::isBlank = ->
  @.trim() is ''

String::strip = ->
  @.replace(/^\s+|\s+$/g, '')

jQuery.fn.outerHTML = ->
  return '' unless @length

  return @[0].outerHTML if @[0].outerHTML

  $('<div>').append(@[0].clone()).remove().html()

moment.fn.toHumanDate = (time = false) ->
  year = if @year() isnt moment().year() then '/YY' else ''

  @format("M/D#{year}#{if time then ' h:mm A' else ''}")
