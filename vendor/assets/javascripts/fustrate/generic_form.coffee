#= require './generic_page'

class Fustrate.GenericForm extends Fustrate.GenericPage
  addEventListeners: =>
    super()

    @root.on 'submit', @onSubmit

  _reloadUIElements: =>
    super()

    for domObject in $('[name]', @root)
      element = $ domObject
      name = element.prop 'name'

      if captures = name.match /\[([a-z0-9_]+)\]/g
        @_setNestedField(captures, element)
      else
        @fields[name] = element

  validate: -> true

  onSubmit: (e) =>
    return true if @validate()

    e.preventDefault()

    setTimeout (=> $.rails.enableFormElements(@root)), 100

    false

  # Modified to remove recursion - no need to pass elements around endlessly.
  _setNestedField: (path, element) ->
    context = @fields
    first = path.shift()
    piece = first.substring(1, first.length - 1)

    while path.length > 0
      context[piece] ?= {}
      context = context[piece]
      next = path.shift()
      piece = next.substring(1, next.length - 1)

    context[piece] = element
