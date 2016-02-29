class Fustrate.Components.Dropdown extends Fustrate.Components.Base
  @locked: false

  @initialize: ->
    @body = $ 'body'

    @body.on 'click.dropdowns', '.has-dropdown', @open

  @open: (event) =>
    @hide()

    button = $ event.currentTarget
    dropdown = $ '+ .dropdown', button

    @locked = true

    if button.position().top > (@body.height() / 2)
      top = button.position().top - dropdown.outerHeight() - 2
    else
      top = button.position().top + button.outerHeight() + 2

    if button.position().left > (@body.width() / 2)
      left = 'inherit'
      right = @body.width() - button.position().left - button.outerWidth()
    else
      right = 'inherit'
      left = button.position().left

    @showDropdown dropdown, left: left, top: top, right: right

    false

  @showDropdown: (dropdown, css) ->
    dropdown
      .addClass 'visible'
      .hide()
      .css css
      .fadeIn 200, =>
        @locked = false

        @body.one 'click', @hide

  @hide: =>
    return if @locked

    $('.dropdown.visible')
      .removeClass 'visible'
      .fadeOut 200
