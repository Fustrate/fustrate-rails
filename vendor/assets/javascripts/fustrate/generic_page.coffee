class Fustrate.GenericPage
  constructor: (@root) ->
    @_reloadUIElements()
    @addEventListeners()
    @initialize()

  include: (concern) =>
    instance = new concern

    for own key, value of instance.constructor
      continue if key in ['included', 'initialize']

      @constructor[key] = value unless @constructor[key]

    # Assign properties to the prototype
    for key, value of concern.prototype
      continue if key in ['included', 'initialize']

      @[key] = value.bind(@) unless @[key]

    instance.included?.apply(@)

  addEventListeners: =>
    for name, func of @
      # Edge returns true for /one.+two/.test('onetwo'), 2017-10-21
      func.apply(@) if /^add..*EventListeners$/.test name

  # Once the interface is loaded and the event listeners are active, run any
  # other tasks.
  initialize: ->

  _reloadUIElements: =>
    @fields = {}
    @buttons = {}

    $('[data-field]', @root).not('.modal [data-field]').each (i, element) =>
      @fields[element.dataset.field] = $ element

    $('[data-button]', @root).not('.modal [data-button]').each (i, element) =>
      @buttons[element.dataset.button] = $ element

  flashSuccess: (message, { icon } = {}) ->
    new Fustrate.Components.Flash.Success(message, icon: icon)

  flashError: (message, { icon } = {}) ->
    new Fustrate.Components.Flash.Error(message, icon: icon)

  flashInfo: (message, { icon } = {}) ->
    new Fustrate.Components.Flash.Info(message, icon: icon)

  setHeader: (text) ->
    $('.header > span', @root).text text

  # Calls all methods matching /refresh.+/
  refresh: =>
    for own name, func of @
      func() if name.indexOf('refresh') is 0 and name isnt 'refresh'
