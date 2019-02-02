class Fustrate.Record extends Fustrate.Object
  # Rails class name
  @class: null

  @define 'class', get: ->
    @constructor.class

  constructor: (data) ->
    @_loaded = false

    super(data)

    if typeof data is 'number' or typeof data is 'string'
      # If the parameter was a number or string, it's likely the record ID
      @id = parseInt(data, 10)
    else
      # Otherwise we were probably given a hash of attributes
      @extractFromData data

  reload: ({ force } = {}) =>
    return $.when() if @_loaded and not force

    $.get(@path(format: 'json')).done (response) =>
      @extractFromData(response)
      @_loaded = true

  save: (params = {}) =>
    url = if @id
      @path(format: 'json')
    else
      Routes[@constructor.create_path](format: 'json')

    data = @_toFormData()
    data.append(key, value) for own key, value of params if params
      
    $.ajax
      url: url
      data: data
      processData: false
      contentType: false
      method: if @id then 'PATCH' else 'POST'
      xhr: =>
        xhr = $.ajaxSettings.xhr()

        xhr.upload.onprogress = (e) =>
          @trigger 'upload_progress', e

        xhr
    .done @extractFromData

  update: (data, params) =>
    @extractFromData(data)
    @save(params)

  delete: =>
    $.ajax @path(format: 'json'),
      method: 'DELETE'

  toParams: -> {}

  _toFormData: (data, object, namespace) =>
    data ?= new FormData
    object ?= @toParams()

    for own field, value of object when typeof value isnt 'undefined'
      key = if namespace then "#{namespace}[#{field}]" else field

      if value and typeof value is 'object'
        if value instanceof Array
          data.append "#{key}[]", array_value for array_value in value
        else if value instanceof File
          data.append key, value
        else
          @_toFormData(data, value, key)
      else if typeof value is 'boolean'
        data.append key, Number(value)
      else if value isnt null and value isnt undefined
        data.append key, value

    data
