class Fustrate.GenericPage
  constructor: (@root) ->
    @_reloadUIElements()
    @addEventListeners()
    @initialize()

  include: (concern) =>
    instance = new concern

    for own key, value of instance.constructor
      continue if key in ['included', 'initialize', 'strings']

      @constructor[key] = value unless @constructor[key]

    # Assign properties to the prototype
    for key, value of concern.prototype
      continue if key in ['included', 'initialize', 'strings']

      @[key] = value.bind(@) unless @[key]

    instance.included?.apply(@)

    return unless instance.constructor.strings

    @constructor.strings ?= {}

    $.extend true, @constructor.strings, instance.constructor.strings

  addEventListeners: =>
    super

    for name, func of @
      func.apply(@) if /^add.+EventListeners$/.test name

  # Once the interface is loaded and the event listeners are active, run any
  # other tasks.
  initialize: ->

  _reloadUIElements: =>
    @fields = {}
    @buttons = {}

    $('[data-field]', @root).not('.modal [data-field]').each (i, element) =>
      field = $ element
      @fields[field.data('field')] = field

    $('[data-button]', @root).not('.modal [data-button]').each (i, element) =>
      button = $ element
      @buttons[button.data('button')] = button

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
