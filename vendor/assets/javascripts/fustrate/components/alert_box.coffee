class Fustrate.Components.AlertBox extends Fustrate.Components.Base
  @fadeSpeed: 300

  @initialize: ->
    $('.alert-box').on 'click', '.close', (e) ->
      event.preventDefault()

      alert_box = $(e.currentTarget).closest('.alert-box')

      alert_box.fadeOut @constructor.fadeSpeed, -> alert_box.remove()

      false
