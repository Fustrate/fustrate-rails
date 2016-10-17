#= require './generic_page'

class Fustrate.GenericForm extends Fustrate.GenericPage
  addEventListeners: =>
    super

    @root.on 'submit', @onSubmit

  _reloadUIElements: =>
    super

    for domObject in $('[name][id]', @root)
      element = $ domObject
      name = element.prop 'name'

      if captures = name.match /\[([a-z_]+)\]$/
        @fields[captures[1]] = element
      else
        @fields[name] = element

  validate: -> true

  onSubmit: (e) =>
    return true if @validate()

    e.preventDefault()

    setTimeout (=> $.rails.enableFormElements(@root)), 100

    false
