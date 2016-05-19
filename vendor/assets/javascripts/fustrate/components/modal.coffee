class Fustrate.Components.Modal extends Fustrate.Components.Base
  @fadeSpeed: 250

  @settings:
    closeOnBackgroundClick: true
    distanceFromTop: 25
    appendTo: 'body'
    css:
      open:
        opacity: 0
        visibility: 'visible'
        display: 'block'
      close:
        opacity: 1
        visibility: 'hidden'
        display: 'none'
    _cachedHeight: undefined

  constructor: ({title, content, size, settings}) ->
    @modal = @constructor.createModal size: size
    @settings = $.extend true, @constructor.settings, (settings ? {})
    @settings.previousModal = $()

    @setTitle title
    @setContent content

    @_reloadUIElements()
    @addEventListeners()
    @initialize()

    super

  initialize: ->

  _reloadUIElements: =>
    @fields = {}
    @buttons = {}

    $('[data-field]', @modal).each (index, element) =>
      field = $ element
      @fields[field.data('field')] = field

    $('[data-button]', @modal).each (index, element) =>
      button = $ element
      @buttons[button.data('button')] = button

  setTitle: (title) =>
    $('.modal-title span', @modal).html title

  setContent: (content) =>
    $('.modal-content', @modal).html content

    @settings._cachedHeight = undefined

    @_reloadUIElements()

  addEventListeners: =>
    @modal
      .off '.modal'
      .on 'close.modal', @close
      .on 'open.modal', @open
      .on 'hide.modal', @hide
      .on 'opened.modal', @focusFirstInput
      .on 'click.modal', '.modal-close', @constructor.closeButtonClicked

    # TODO: Re-enable when modals are fully converted
    #   .off '.modal'
    $(document).on 'click.modal touchstart.modal',
                   '.modal-overlay',
                   @constructor.backgroundClicked

  focusFirstInput: =>
    # Focus requires a slight physical scroll on iOS 8.4
    return true if /iPad|iPhone|iPod/g.test navigator.userAgent

    $('input, select', @modal)
      .filter(':visible:not(:disabled):not([readonly])')
      .first()
      .focus()

  open: =>
    return if @modal.hasClass('locked') || @modal.hasClass('open')

    @modal.addClass('locked')

    # If there is currently a modal being shown, store it and re-open it when
    # this modal closes.
    @settings.previousModal = $('.modal.open')

    # These events only matter when the modal is visible
    $('body')
      .off 'keyup.modal'
      .on 'keyup.modal', (e) =>
        return if @modal.hasClass('locked') || e.which != 27

        @close()

    @modal.trigger 'opening.modal'

    @_cacheHeight() if typeof @settings._cachedHeight == 'undefined'

    if @settings.previousModal.length
      @settings.previousModal.trigger('hide.modal')
    else
      # There are no open modals - show the background overlay
      @constructor.toggleBackground true

    css = @settings.css.open
    # css.top = parseInt @modal.css('top'), 10

    css.top = $(window).scrollTop() - @settings._cachedHeight + 'px'

    end_css =
      top: $(window).scrollTop() + @settings.distanceFromTop + 'px',
      opacity: 1

    setTimeout (=>
      @modal
        .css css
        .addClass('open')
        .animate end_css, 250, 'linear', =>
          @modal.removeClass('locked').trigger('opened.modal')
    ), 125

  close: (openPrevious = true) =>
    return if @modal.hasClass('locked') || !@modal.hasClass('open')

    @modal.addClass 'locked'

    $('body').off 'keyup.modal'

    unless @settings.previousModal.length && openPrevious
      @constructor.toggleBackground(false)

    end_css =
      top: - $(window).scrollTop() - @settings._cachedHeight + 'px',
      opacity: 0

    setTimeout (=>
      @modal
        .animate end_css, 250, 'linear', =>
          @modal
            .css @settings.css.close
            .removeClass 'locked'
            .trigger 'closed.modal'

          if openPrevious
            @openPreviousModal()
          else
            @settings.previousModal = $()

        .removeClass('open')
    ), 125

  # Just hide the modal immediately and don't bother with an overlay
  hide: =>
    @modal.removeClass('open locked').css @settings.css.close

  openPreviousModal: =>
    @settings.previousModal.trigger 'open.modal'

    @settings.previousModal = $()

  _cacheHeight: =>
    @settings._cachedHeight = @modal.show().height()

    @modal.hide()

  @createModal: ({size}) ->
    $("""
      <div class="modal #{size ? 'tiny'}">
        <div class="modal-title">
          <span></span>
          <a href="#" class="modal-close">&#215;</a>
        </div>
        <div class="modal-content"></div>
      </div>""").appendTo(@settings.appendTo)

  @toggleBackground: (visible = true) =>
    @overlay = $ '<div class="modal-overlay">' unless @overlay

    if visible
      return if @overlay.is(':visible')

      @overlay
        .hide()
        .appendTo('body')
        .fadeIn @fadeSpeed
    else
      @overlay
        .fadeOut @fadeSpeed, ->
          $(@).detach()

  @backgroundClicked: ->
    modal = $ '.modal.open'

    return if !modal || modal.hasClass('locked')

    # Don't continue to close if we're not supposed to
    return unless Fustrate.Components.Modal.settings.closeOnBackgroundClick

    modal.trigger 'close.modal'

    false

  @closeButtonClicked: ->
    modal = $ '.modal.open'

    return if !modal || modal.hasClass('locked')

    modal.trigger 'close.modal'

    false
