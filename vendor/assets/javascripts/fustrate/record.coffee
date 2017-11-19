class Fustrate.Record extends Fustrate.Object
  # Rails class name
  @class: null

  reload: =>
    $.get(@path(format: 'json')).done @extractFromData

  constructor: (data) ->
    super

    if typeof data is 'number' or typeof data is 'string'
      # If the parameter was a number or string, it's likely the record ID
      @id = parseInt(data, 10)
    else
      # Otherwise we were probably given a hash of attributes
      @extractFromData data

  save: =>
    url = if @id
      @path(format: 'json')
    else
      Routes[@constructor.create_path](format: 'json')

    $.ajax
      url: url
      data: @_toFormData()
      processData: false
      contentType: false
      method: if @id then 'PATCH' else 'POST'
      xhr: =>
        xhr = $.ajaxSettings.xhr()

        xhr.upload.onprogress = (e) =>
          @trigger 'upload_progress', e

        xhr
    .done @extractFromData

  update: (data) =>
    @extractFromData data
    @save()

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
      else
        data.append key, value

    data
