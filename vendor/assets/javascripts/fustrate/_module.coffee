#= require_self
#= require_directory .
#= require_tree .

class window.Fustrate
  @VERSION: '0.3.4'
  @libs: {}

  constructor: ->
    lib.init() for own name, lib of @constructor.libs

    for own component of Fustrate.Components
      Fustrate.Components[component].initialize()

    @initialize()

  initialize: ->
    $('[data-js-class]').each (index, elem) ->
      element = $(elem)
      klass = Fustrate._stringToClass element.data('js-class')

      element.data 'js-object', new klass(element)

    $.ajaxSetup
      cache: false
      beforeSend: $.rails.CSRFProtection

    $('table').wrap '<div class="responsive-table"></div>'

    $('.number').each (index, elem) ->
      elem = $ @

      number = if elem.data('number') isnt undefined
        elem.data('number')
      else
        elem.html()

      elem.addClass 'negative' if parseInt(number, 10) < 0

  @_stringToClass: (string) ->
    pieces = string.split('.')

    Fustrate._arrayToClass(pieces, window)

  @_arrayToClass: (pieces, root) ->
    return root[pieces[0]] if pieces.length is 1

    Fustrate._arrayToClass pieces.slice(1), root[pieces[0]]

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

  @humanDate: (date, time = false) ->
    if date.year() is moment().year()
      date.format("M/D#{if time then ' h:mm A' else ''}")
    else
      date.format("M/D/YY#{if time then ' h:mm A' else ''}")

  @label: (text, type) ->
    type = if type then "#{type} " else ''

    $('<span>')
      .text(text)
      .prop('class', "label #{type}#{text}".toLowerCase())

  @icon: (types) ->
    classes = ("fa-#{type}" for type in types.split(' ')).join(' ')

    "<i class=\"fa #{classes}\"></i>"

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

jQuery.fn.outerHTML = ->
  return '' unless @length

  return @[0].outerHTML if @[0].outerHTML

  $('<div>').append(@[0].clone()).remove().html()
