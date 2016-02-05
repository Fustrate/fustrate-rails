class Fustrate.Components.Autocomplete extends Fustrate.Components.Base
  @types:
    plain:
      displayKey: 'value'
      item: (object, userInput) -> "<li>#{@highlight object.value}</li>"
      filter: (object, userInput) -> object.value.indexOf(userInput) >= 0

  @initialize: ->
    # Override the default sort
    Awesomplete.SORT_BYLENGTH = ->

  constructor: (@input, types) ->
    if $.isArray types
      types = {
        plain:
          list: types.map (value) -> { value: value }
      }

    @sources = for own type, options of types
      $.extend({}, @constructor.types[type], options)

    @sources = [@sources] if $.isPlainObject @sources

    existing = @input.data('awesomplete')

    if existing
      existing.sources = @sources
      return

    @awesomplete = new Awesomplete(
      @input[0]
      minChars: 0
      maxItems: 25
      filter: -> true
      item: (option, userInput) -> option # Items are pre-rendered
    )

    @input
      .data 'awesomplete', @
      .on 'awesomplete-highlight', @onHighlight
      .on 'awesomplete-select', @onSelect
      .on 'keyup', @constructor.debounce(@onKeyup)
      .on 'focus', @onFocus

  blanked: =>
    return unless @input.val().trim() == ''

    @awesomplete.close()

    $("~ input:hidden##{@input.attr('id')}_id", @awesomplete.container)
      .val null
    $("~ input:hidden##{@input.attr('id')}_type", @awesomplete.container)
      .val null

    @input.trigger 'blanked.autocomplete'

  onFocus: =>
    @items = []
    @value = @input.val().trim() ? ''

    for source in @sources when source.list?.length
      for datum in source.list when source.filter(datum, @value)
        @items.push @createListItem(datum, source)

    @awesomplete.list = @items
    @awesomplete.evaluate()

  onHighlight: =>
    item = $('+ ul li[aria-selected="true"]', @input)

    return unless item[0]

    item[0].scrollIntoView false
    @replace item.data('datum')._displayValue

  onSelect: (e) =>
    # aria-selected isn't set on click
    item = $(e.originalEvent.origin).closest('li')
    datum = item.data('datum')

    @replace datum._displayValue
    @awesomplete.close()

    $("~ input:hidden##{@input.attr('id')}_id", @awesomplete.container)
      .val datum.id
    $("~ input:hidden##{@input.attr('id')}_type", @awesomplete.container)
      .val datum._type

    @input.data(datum: datum).trigger('finished.autocomplete')

    false

  onKeyup: (e) =>
    keyCode = e.which || e.keyCode

    value = @input.val().trim()

    return @blanked() if value == ''

    # Ignore: Tab, Enter, Esc, Left, Up, Right, Down
    return if keyCode in [9, 13, 27, 37, 38, 39, 40]

    # Don't perform the same search twice in a row
    return unless value != @value && value.length >= 2

    @value = value
    @items = []

    for source in @sources
      if source.url?
        @performSearch(source)
      else if source.list?
        for datum in source.list when source.filter(datum, @value)
          @items.push @createListItem(datum, source)

        @awesomplete.list = @items

  performSearch: (source) =>
    $.get source.url(search: @value, commit: 1, format: 'json')
    .done (response) =>
      for datum in response
        @items.push @createListItem(datum, source)

      @awesomplete.list = @items

  createListItem: (datum, source) ->
    datum._displayValue = datum[source.displayKey]
    datum._type = source.type

    $ source.item.call(@, datum, @value)
      .data datum: datum
      .get(0)

  highlight: (text) =>
    return '' unless text

    text.replace RegExp("(#{@value.split(/\s+/).join('|')})", 'gi'),
                 '<mark>$&</mark>'

  replace: (text) =>
    @awesomplete.replace(text)

  @debounce: (func, milliseconds = 300, immediate = false) ->
    timeout = null

    (args...) ->
      delayed = =>
        func.apply(@, args) unless immediate
        timeout = null

      if timeout
        clearTimeout(timeout)
      else if immediate
        func.apply(@, args)

      timeout = setTimeout delayed, milliseconds

  @addType: (name, func) =>
    @types[name] = func

  @addTypes: (types) ->
    @addType(name, func) for own name, func of types
