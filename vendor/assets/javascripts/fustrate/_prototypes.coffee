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

Number::bytesToString = ->
  return "#{@} B" if @ < 1000

  return "#{(@ / 1000).toFixed(2).replace(/\.?0+$/, '')} kB" if @ < 1000000

  if @ < 1000000000
    return "#{(@ / 1000000).toFixed(2).replace(/\.?0+$/, '')} MB"

  "#{(@ / 1000000000).toFixed(2).replace(/\.?0+$/, '')} GB"

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

String::isBlank = ->
  @trim() is ''

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
