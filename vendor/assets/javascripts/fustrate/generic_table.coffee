class Fustrate.GenericTable extends Fustrate.GenericPage
  @blankRow: null
  table: null

  initialize: =>
    super()

    @reloadTable()

  reloadTable: ->

  sortRows: (rows, sortFunction = ->) ->
    sorted = ([sortFunction(row), row] for row in rows)
    sorted.sort (x, y) ->
      if x[0] is y[0] then 0 else if x[0] > y[0] then 1 else -1
    sorted.map (row) -> row[1]

  createRow: (item) =>
    if typeof @constructor.blankRow is 'function'
      @updateRow $(@constructor.blankRow()), item
    else
      @updateRow $(@constructor.blankRow), item

  updateRow: (row, item) ->
    row

  reloadRows: (rows, { sort } = { sort: null }) =>
    tbody = $ 'tbody', @table

    $('tr.loading', tbody).hide()

    if rows
      $('tr:not(.no-records):not(.loading)', tbody).remove()

      tbody.append if sort then @sortRows(rows, sort) else rows

    @updated()

  addRow: (row) =>
    $('tbody', @table).append row
    @updated()

  removeRow: (row) =>
    row.fadeOut =>
      row.remove()
      @updated()

  updated: =>
    $('tbody tr.no-records', @table)
      .toggle $('tbody tr:not(.no-records):not(.loading)', @table).length < 1

  getCheckedIds: =>
    (item.value for item in $('td:first-child input:checked', @table))

  # This should be fed a response from a JSON request for a paginated
  # collection.
  updatePagination: (response) =>
    return unless response.totalPages

    @pagination = new Fustrate.Components.Pagination response

    $('.pagination', @root).replaceWith @pagination.generate()
