class Fustrate.GenericTable extends Fustrate.GenericPage
  @blankRow: null
  table: null

  initialize: =>
    super

    @reloadTable()

  reloadTable: ->

  sortRows: (rows, sortFunction = ->) ->
    ([sortFunction(row), row] for row in rows)
      .sort (x, y) -> if x[0] == y[0] then 0 else x[0] > y[0]
      .map (row) -> row[1]

  createRow: (item) =>
    @updateRow @constructor.blankRow.clone(), item

  updateRow: (row, item) ->
    row

  reloadRows: (rows, {sort} = { sort: null }) =>
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

  # This should be fed a response from a JSON request for a paginated
  # collection.
  updatePagination: (response) =>
    @pagination = new Fustrate.Components.Pagination response

    $('.pagination', @root).replaceWith @pagination.generate()
