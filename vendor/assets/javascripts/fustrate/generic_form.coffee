#= require './generic_page'

class Fustrate.GenericForm extends Fustrate.GenericPage
  _reloadUIElements: =>
    super

    for domObject in $('[name][id]', @root)
      element = $ domObject
      name = element.prop 'name'

      if captures = name.match /\[([a-z_]+)\]$/
        @fields[captures[1]] = element
      else
        @fields[name] = element
