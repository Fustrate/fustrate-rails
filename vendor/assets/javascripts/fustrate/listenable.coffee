class Fustrate.Listenable
  constructor: ->
    @listeners = {}

  on: (eventNames, callback) =>
    for eventName in eventNames.split(' ')
      @listeners[eventName] = [] unless @listeners[eventName]
      @listeners[eventName].push callback

    @

  off: (eventNames) =>
    for eventName in eventNames.split(' ')
      @listeners[eventName] = []

    @

  trigger: =>
    [name, args...] = arguments

    return @ unless name and @listeners[name]

    event.apply(@, args) for event in @listeners[name]

    @
