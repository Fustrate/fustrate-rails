class Fustrate.Record extends Fustrate.Object
  # Rails class name
  @class: null

  constructor: (data) ->
    super

    if typeof data is 'number' or typeof data is 'string'
      # If the parameter was a number or string, it's likely the record ID
      @id = parseInt(data, 10)
    else
      # Otherwise we were probably given a hash of attributes
      @extractFromData data

  reload: ->

  save: ->

  toObject: -> {}

  update: (data) =>
    @extractFromData data
    @save()
