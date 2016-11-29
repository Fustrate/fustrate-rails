class Fustrate.GenericPage
  constructor: (@root) ->
    @_reloadUIElements()
    @addEventListeners()
    @initialize()

  addEventListeners: ->

  # Once the interface is loaded and the event listeners are active, run any
  # other tasks.
  initialize: ->

  _reloadUIElements: =>
    @fields = {}
    @buttons = {}

    $('[data-field]', @root).not('.modal [data-field]').each (index, element) =>
      field = $ element
      @fields[field.data('field')] = field

    $('[data-button]', @root).not('.modal [data-button]').each (index, element) =>
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
