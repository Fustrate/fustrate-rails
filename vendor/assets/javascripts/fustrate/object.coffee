class Fustrate.Object extends Fustrate.Listenable
  constructor: (data) ->
    @extractFromData data

    super(data)

  # Simple extractor to assign root keys as properties in the current object.
  # Formats a few common attributes as dates with moment.js
  extractFromData: (data) =>
    @[key] = value for key, value of data

    @date = moment @date if @date
    @created_at = moment @created_at if @created_at
    @updated_at = moment @updated_at if @updated_at

  # Instantiate a new object of type klass for each item in items
  _createList: (items, klass, additional_attributes = {}) ->
    for item in items
      new klass $.extend(true, {}, item, additional_attributes)
