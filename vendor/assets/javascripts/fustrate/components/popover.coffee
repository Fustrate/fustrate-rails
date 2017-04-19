class Fustrate.Components.Popover extends Fustrate.Components.Base
  @initialize: ->
    @cache = {}
    @container = $ '.container-content > .row'

    $('[data-popover-url]').click @togglePopover
    $('body').on 'click.popover', @hidePopover

  @togglePopover: (event) =>
    path = event.currentTarget.dataset.popoverUrl

    # Hide if the url is the same, hide and show a new one if it's different
    createNew = (not @popover) or (@popover.data('popover-url') isnt path)

    @popover?.hide().remove()
    @popover = undefined

    @createPopover(event) if createNew

    false

  @createPopover: (event) =>
    path = event.currentTarget.dataset.popoverUrl

    @popover = $('<div class="popover"></div>')
      .appendTo('body')
      .data('popover-url', path)

    if @cache[path]
      @setContent @cache[path], event
      @popover.fadeIn 100
    else
      $.get(path).done (html) =>
        @cache[path] = html

        @setContent html, event

  @setContent: (html, event) =>
    target = $ event.currentTarget

    @popover.html html

    css =
      left: @container.offset().left + 20
      right: $(window).width() - target.offset().left + 10
      overflow: 'scroll'

    windowHeight = $(window).height()

    # Distance scrolled from top of page
    scrollTop = $(window).scrollTop()

    offsetTop = target.offset().top
    height = target.outerHeight()

    distanceFromTop = offsetTop - scrollTop
    distanceFromBottom = windowHeight + scrollTop - offsetTop - height

    if distanceFromTop < distanceFromBottom
      css.top = offsetTop - Math.min(distanceFromTop, 0) + 10
      css.maxHeight = distanceFromBottom + height - 20
    else
      css.bottom = windowHeight - target.position().top - height -
        Math.min(distanceFromBottom, 0) - 40
      css.maxHeight = distanceFromTop - 10

    @popover.css(css)

  @hidePopover: (event) =>
    return unless @popover

    return if $(event.target).parents('.popover').length > 0

    @popover.hide().remove()
    @popover = undefined
