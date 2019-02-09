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

  update: (attributes = {}) =>
    if @id
      url = @path(format: 'json')
    else
      @extractFromData(attributes)
      url = Routes[@constructor.create_path](format: 'json')

    if @community and attributes.community_id is undefined
      attributes.community_id = @community.id

    formData = @_toFormData(new FormData, attributes, @constructor.paramKey())

    $.ajax
      url: url
      data: formData
      processData: false
      contentType: false
      method: if @id then 'PATCH' else 'POST'
      xhr: =>
        xhr = $.ajaxSettings.xhr()

        xhr.upload.onprogress = (e) =>
          @trigger 'upload_progress', e

        xhr
    .done @extractFromData

  delete: =>
    $.ajax @path(format: 'json'),
      method: 'DELETE'

  _toFormData: (data, object, namespace) =>
    for own field, value of object when typeof value isnt 'undefined'
      key = if namespace then "#{namespace}[#{field}]" else field

      if value and typeof value is 'object'
        @_appendObjectToFormData(data, key, value)
      else if typeof value is 'boolean'
        data.append key, Number(value)
      else if value isnt null and value isnt undefined
        data.append key, value

    data

  _appendObjectToFormData: (data, key, value) =>
    if value instanceof Array
      data.append "#{key}[]", array_value for array_value in value
    else if value instanceof File
      data.append key, value
    else if moment.isMoment(value)
      data.append key, value.format()
    else if not (value instanceof Fustrate.Record)
      @_toFormData(data, value, key)

  @paramKey: ->
    @class.underscore().replace('/', '_')

  @buildList: (items, additional_attributes = {}) ->
    for item in items
      new @ $.extend(true, {}, item, additional_attributes)

  @create: (attributes) ->
    record = new @

    $.Deferred (@deferred) =>
      record.update(attributes).fail(@deferred.reject).done =>
        @deferred.resolve record
