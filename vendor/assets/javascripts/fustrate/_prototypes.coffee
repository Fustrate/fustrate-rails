# Replicate a few common prototype methods on default objects

Array::compact = (strings = true) ->
  @forEach (el, index) =>
    return unless el is undefined or el is null or (strings and el is '')

    @splice(index, 1)

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

Number::bytesToString = ->
  return "#{@} B" if @ < 1000

  return "#{(@ / 1000).truncate()} kB" if @ < 1000000

  return "#{(@ / 1000000).truncate()} MB" if @ < 1000000000

  "#{(@ / 1000000000).truncate()} GB"

Number::ordinalize = ->
  s = ['th', 'st', 'nd', 'rd']
  v = @ % 100
  @ + (s[(v - 20) % 10] or s[v] or 'th')

Number::truncate = (digits = 2) ->
  @toFixed(digits).replace(/\.?0+$/, '')

String::capitalize = ->
  @charAt(0).toUpperCase() + @slice(1)

String::dasherize = ->
  @replace /_/g, '-'

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

# This is far too simple for most cases, but it works for the few things we need
String::pluralize = ->
  if @[@length - 1] is 'y'
    return @substr(0, @length - 1) + 'ies'

  @ + 's'

String::presence = ->
  if @isBlank() then null else @

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
