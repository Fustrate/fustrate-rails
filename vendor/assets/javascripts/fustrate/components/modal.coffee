class Fustrate.Components.Modal extends Fustrate.Components.Base
  @background: undefined
  @fadeSpeed: 250
  @openModal: undefined

  @settings:
    closeOnBackgroundClick: true
    distanceFromTop: 25
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
    @setTitle title
    @setContent content

    @settings = $.extend true, @constructor.settings, (settings ? {})

    @locked = false
    @previousModal = undefined

    @_reloadUIElements()
    @addEventListeners()

    super

  @createModal: ({size}) ->
    $ """
      <div class="modal #{size ? 'tiny'}">
        <div class="modal-title">
          <span></span>
          <a href="#" class="modal-close">&#215;</a>
        </div>
        <div class="modal-content"></div>
      </div>"""

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

    @_reloadUIElements()

  addEventListeners: =>
    @modal
      .off '.modal'
      .on 'hide.modal close.modal', @close
      .on 'show.modal open.modal', @open
      .on 'opened.modal', @focusFirstInput
      .on 'click.modal', '.modal-close', @closeButtonClicked

    # TODO: Re-enable when modals are fully converted
    #   .off '.modal'
    $(document)
      .on 'click.modal touchstart.modal', '.modal-overlay', @backgroundClicked

  backgroundClicked: (e) =>
    return if !@constructor.openModal || @constructor.openModal.locked

    # Don't continue to close if we're not supposed to
    return unless @constructor.openModal.settings.closeOnBackgroundClick

    e.preventDefault()
    e.stopPropagation()

    @close()

    false

  closeButtonClicked: (e) =>
    return if !@constructor.openModal || @constructor.openModal.locked

    e.preventDefault()

    @close()

    false

  focusFirstInput: =>
    # Focus requires a slight physical scroll on iOS 8.4
    return true if /iPad|iPhone|iPod/g.test navigator.userAgent

    $('input, select', @modal)
      .filter(':visible:not(:disabled):not([readonly])')
      .first()
      .focus()

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

  open: =>
    return if @locked || @modal.hasClass 'open'

    @locked = true

    # If there is currently a modal being shown, store it and re-open it when
    # this modal closes.
    @previousModal = @constructor.openModal

    # These events only matter when the modal is visible
    $('body')
      .off 'keyup.modal'
      .on 'keyup.modal', (e) =>
        return if @locked || e.which != 27

        @close()

    @modal.trigger 'opening.modal'

    @_cacheHeight() if typeof @settings._cachedHeight == 'undefined'

    if @previousModal
      @previousModal.close()
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
          @locked = false
          @modal.trigger 'opened.modal'
          @constructor.openModal = @
    ), 125

  close: =>
    return if @locked || !@modal.hasClass 'open'

    @locked = true

    $('body').off 'keyup.modal'

    close_event = $.Event 'close.modal'
    @modal.trigger close_event

    return if close_event.isDefaultPrevented()

    @constructor.toggleBackground(false) unless @previousModal

    end_css =
      top: - $(window).scrollTop() - @settings._cachedHeight + 'px',
      opacity: 0

    setTimeout (=>
      @modal
        .animate end_css, 250, 'linear', =>
          @locked = false
          @modal.css @settings.css.close
          @modal.trigger 'closed.modal'
          @constructor.openModal = undefined
          @openPreviousModal()
        .removeClass('open')
    ), 125

  openPreviousModal: =>
    @previousModal?.open()

    @previousModal = undefined

  # If this modal hasn't been attached to a relatively positioned element,
  # attach it to #content
  attachToContent: =>
    return if @modal.parent('#content').length > 0

    # placeholder = @modal.wrap('<div style="display: none;" />').parent()

    @modal.detach().appendTo '#content'

  _cacheHeight: =>
    @attachToContent()

    @settings._cachedHeight = @modal.show().height()

    @modal.hide()
