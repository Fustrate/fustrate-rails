class Fustrate.Components.Autocomplete extends Fustrate.Components.Base
  # Store URLs that we try to match filters for
  @filters: []

  class @Remote
    constructor: (input, types, options) ->
      @input = $ input

      @options =
        remote: @constructor.urlsForTypes(types ? @input.data('autocomplete'))
        templates:
          default: '''
            <span class="title">{{title}}</span>
            <span class="code">{{code}}</span>
            <ul class="description"><li>{{description}}</li></ul>'''
        displayKey: 'title'
        onSelect: @onSelect

      @options = $.extend true, {}, @options, options if options

      @input
        .autocomplete @options
        .off '.autocomplete'
        .on 'change.autocomplete', @onChange

    onChange: =>
      return unless @input.val().length < 1

      $("[data-autocomplete-id=#{@data 'autocomplete-id'}]").val ''

      @data 'datum', null

    onSelect: (e, datum) =>
      @input
        .data 'datum', datum
        .typeahead 'val', datum.title

      autocomplete_id = @input.data('autocomplete-id')

      $(".id_field[data-autocomplete-id=#{autocomplete_id}]")
        .val datum.id
      $(".type_field[data-autocomplete-id=#{autocomplete_id}]")
        .val datum.type

    @urlsForTypes: (types) ->
      list = if $.isArray(types) then types else types.split(' ')

      list.map (type) -> "/#{type}/search.json?search=%QUERY&commit=Search"

  class @Local
    constructor: (input, suggestions, options) ->
      @input = $ input

      locals = for suggestion in suggestions
        if $.isPlainObject(suggestion)
          suggestion
        else
          { title: suggestion }

      @options =
        displayKey: 'title'
        minLength: 0
        local: locals
        templates:
          default: '''
            <span class="title">{{title}}</span>
            <span class="code">{{code}}</span>
            <ul class="description"><li>{{description}}</li></ul>'''
          empty: ''

      @options = $.extend true, {}, @options, options if options

      @input.autocomplete @options

  @filterForUrl: (url) ->
    return filter[1] for filter in @filters when filter[0].test(url)

    (response) -> response

  @addFilter: (regex, func) =>
    @filters.push [new RegExp(regex), func]

  @addFilters: (filters) ->
    @addFilter(regex, func) for own regex, func of filters

  @initialize: =>
    $('[data-autocomplete]').each (index, elem) =>
      new @Remote elem

$.fn.autocomplete = (options) ->
  return @ unless @length

  defaults =
    name:           "Autocomplete#{Math.floor(Math.random() * 1000)}"
    minLength:      2
    hint:           false
    limit:          25
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace d.val
    queryTokenizer: Bloodhound.tokenizers.whitespace
    onSelect: ->
    templates:
      empty: '<div class="no-results">No results found</div>'

  if options.displayKey?
    unless options.datumTokenizer?
      defaults.datumTokenizer = (d) ->
        Bloodhound.tokenizers.whitespace d[options.displayKey]

    defaults.templates.default =
      "<span class=\"title\">{{#{options.displayKey}}}</span>"

  options = $.extend true, {}, defaults, options

  @each (index, elem) ->
    datasets = []

    if options.remote?
      remotes = if $.isArray(options.remote)
        options.remote
      else
        [options.remote]

      remotes.forEach (url, index) ->
        bloodhound = new Bloodhound
          remote:
            url:          url
            filter:       Fustrate.Components.Autocomplete.filterForUrl(url)
          datumTokenizer: options.datumTokenizer
          queryTokenizer: options.queryTokenizer
          limit:          options.limit

        bloodhound.initialize()

        datasets.push
          name:       options.name + (index * 3)
          source:     bloodhound.ttAdapter()
          displayKey: options.displayKey
          templates:
            suggestion: (context) ->
              Hogan.compile(options.templates.default).render(context)
            empty: options.templates.empty

    if options.local?
      bloodhound = new Bloodhound
        local:          options.local
        datumTokenizer: options.datumTokenizer
        queryTokenizer: options.queryTokenizer
        limit:          options.limit

      bloodhound.initialize()

      datasets.push
        name:       options.name + (index * 3 + 1)
        source:     bloodhound.ttAdapter()
        displayKey: options.displayKey
        templates:
          suggestion: (context) ->
            Hogan.compile(options.templates.default).render(context)
          empty: options.templates.empty

    if options.prefetch?
      bloodhound = new Bloodhound
        prefetch:       options.prefetch
        datumTokenizer: options.datumTokenizer
        queryTokenizer: options.queryTokenizer
        limit:          options.limit

      bloodhound.initialize()

      datasets.push
        name:       options.name + (index * 3 + 2)
        source:     bloodhound.ttAdapter()
        displayKey: options.displayKey
        templates:
          suggestion: (context) ->
            Hogan.compile(options.templates.default).render(context)
          empty: options.templates.empty

    if datasets.length == 0
      throw new Error 'Autocomplete must have at least one source'

    $(elem).typeahead({
      minLength: options.minLength
      hint:      options.hint
    }, datasets)
    .on 'typeahead:selected typeahead:autocompleted', (e, datum) ->
      options.onSelect(e, datum)
      $(elem)
        .data 'datum', datum
        .trigger 'typeahead:finished', datum
