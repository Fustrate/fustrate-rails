class Fustrate.Components.Tooltip extends Fustrate.Components.Base
  @tooltips: {}
  @fadeSpeed: 100

  constructor: (element, title) ->
    @element = $ element
    @active = false

    @addEventListeners()

    @element.attr('title', title) if title

    @generateId()

    @constructor.tooltips[@id] = @

  generateId: =>
    if @element.data('tooltip_id')
      @id = @element.data('tooltip_id')
    else
      @id = Math.random().toString(36).substr(2, 5)
      @element.data('tooltip_id', @id)

  addEventListeners: =>
    @element
      .on 'mouseover.tooltips', @show
      .on 'mouseleave.tooltips', @hide

  setTitle: (title) ->
    if @active
      @tooltip.text title
    else
      @element.prop('title', title)

  show: (e) =>
    e?.stopPropagation()

    return if @active

    title = @element.prop('title') ? ''

    return unless title.length > 0

    @constructor.hideAll()

    @tooltip ?= $('<span class="tooltip">').hide()

    @element.attr('title', '').removeAttr('title')

    console.log "Fading in #{@id}"

    @tooltip
      .text title
      .appendTo $('body')
      .css
        top: "#{@element.offset().top + @element.height() + 2}px"
        left: "#{@element.offset().left - 2}px"
      .fadeIn @constructor.fadeSpeed, =>
        @active = true

  hide: (e) =>
    e?.stopPropagation()

    return unless @active && @tooltip

    console.log "Fading out #{@id}"

    @tooltip.fadeOut @constructor.fadeSpeed, =>
      @tooltip.detach()
      @element.attr 'title', @tooltip.text()

      @active = false

  isActive: =>
    @visible

  @initialize: ->
    $('[data-tooltip]').each (index, elem) ->
      new Fustrate.Components.Tooltip elem

  @hideAll: =>
    tooltip.hide() for key, tooltip of @tooltips

$.fn.extend
  tooltip: (options) ->
    @each (index, element) ->
      new Fustrate.Components.Tooltip element
