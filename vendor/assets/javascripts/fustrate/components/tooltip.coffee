class Fustrate.Components.Tooltip extends Fustrate.Components.Base
  @fadeSpeed: 100

  constructor: (element, title) ->
    @element = $ element
    @active = false

    @addEventListeners()

    @element.attr('title', title) if title

  addEventListeners: =>
    @element
      .off '.tooltip'
      .on 'mouseenter.tooltip', @_show
      .on 'mousemove.tooltip', @_move
      .on 'mouseleave.tooltip', @_hide

  setTitle: (title) ->
    if @active
      @tooltip.text title
    else
      @element.prop('title', title)

  _move: (e) =>
    e.stopPropagation()

    return unless @active

    @tooltip.css @_tooltipPosition(e)

  _show: (e) =>
    e.stopPropagation()

    return if @active

    title = @element.prop('title') ? ''

    return unless title.length > 0

    @tooltip ?= $('<span class="tooltip">').hide()

    @element.attr('title', '').removeAttr('title')

    @active = true

    @tooltip
      .text title
      .appendTo $('body')
      .css @_tooltipPosition(e)
      .fadeIn @constructor.fadeSpeed

  _hide: (e) =>
    e?.stopPropagation()

    # No use hiding something that doesn't exist.
    return unless @tooltip

    @element.attr 'title', @tooltip.text()
    @active = false

    @tooltip.fadeOut @constructor.fadeSpeed, @tooltip.detach

  _tooltipPosition: (e) ->
    top: "#{e.pageY + 15}px"
    left: "#{e.pageX - 10}px"

  @initialize: ->
    $('[data-tooltip]').each (index, elem) ->
      new Fustrate.Components.Tooltip elem

$.fn.extend
  tooltip: (options) ->
    @each (index, element) ->
      new Fustrate.Components.Tooltip element
