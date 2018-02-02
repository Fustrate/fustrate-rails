# Replicate a few common prototype methods on default objects

Array::compact = (strings = true) ->
  @forEach (element, index) =>
    @splice(index, 1) if element is undefined or (strings and element is '')

  @

Array::first = ->
  @[0]

Array::last = ->
  @[@length - 1]

Array::peek = Array::last

Array::remove = (object) ->
  index = @indexOf object
  @splice index, 1 if index isnt -1

Array::toSentence = ->
  switch @length
    when 0 then ''
    when 1 then @[0]
    when 2 then "#{@[0]} and #{@[1]}"
    else "#{@slice(0, -1).join(', ')}, and #{@[@length - 1]}"

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

# Used to define getters and setters
Function::define = (name, methods) ->
  Object.defineProperty @::, name, methods

Number::accountingFormat = ->
  if @ < 0 then "($#{(@ * -1).toFixed(2)})" else "$#{@.toFixed(2)}"

Number::truncate = (digits = 2) ->
  @toFixed(digits).replace(/\.?0+$/, '')

Number::bytesToString = ->
  return "#{@} B" if @ < 1000

  return "#{(@ / 1000).truncate()} kB" if @ < 1000000

  return "#{(@ / 1000000).truncate()} MB" if @ < 1000000000

  "#{(@ / 1000000000).truncate()} GB"

Object.defineProperty Object::, 'tap',
  enumerable: false
  value: (func) ->
    if typeof func is 'function'
      func.apply(@)
    else
      @[func].apply @, Array::slice.call(arguments).slice(1)

    @

String::capitalize = ->
  @charAt(0).toUpperCase() + @slice(1)

String::dasherize = ->
  @replace /_/g, '-'

# Example:
#   'hello {planet}'.format(planet: 'world') # => 'Hello world'
String::format = ->
  e = @toString()

  return e if not arguments.length

  n = if typeof(arguments[0]) in ['string', 'number']
    Array.prototype.slice.call(arguments)
  else
    arguments[0]

  e.replace /{([^}]+)}/g, (match, key) ->
    if typeof n[key] is 'undefined' then match else n[key]

String::humanize = ->
  @.replace(/[a-z][A-Z]/, (match) -> "#{match[0]} #{match[1]}")
    .replace('_', ' ')
    .toLowerCase()

String::isBlank = ->
  @trim() is ''

String::parameterize = ->
  @.replace(/[a-z][A-Z]/, (match) -> "#{match[0]}_#{match[1]}")
    .replace(/[^a-zA-Z0-9\-_]+/, '-') # Turn unwanted chars into the separator
    .replace(/\-{2,}/, '-') # No more than one of the separator in a row.
    .replace(/^\-|\-$/, '') # Remove leading/trailing separator.
    .toLowerCase()

String::phoneFormat = ->
  if /^1?\d{10}$/.test @
    @replace /1?(\d{3})(\d{3})(\d{4})/, '($1) $2-$3'
  else if /^\d{7}$/.test @
    @replace /(\d{3})(\d{4})/, '$1-$2'
  else
    @

String::strip = ->
  @replace(/^\s+|\s+$/g, '')

String::titleize = ->
  @replace(/_/g, ' ').replace /\b[a-z]/g, (char) -> char.toUpperCase()

String::underscore = ->
  @.replace(/[a-z][A-Z]/, (match) -> "#{match[0]}_#{match[1]}")
    .replace('::', '/')
    .toLowerCase()

jQuery.fn.outerHTML = ->
  return '' unless @length

  return @[0].outerHTML if @[0].outerHTML

  $('<div>').append(@[0].clone()).remove().html()

moment.fn.toHumanDate = (time = false) ->
  year = if @year() isnt moment().year() then '/YY' else ''

  @format("M/D#{year}#{if time then ' h:mm A' else ''}")
