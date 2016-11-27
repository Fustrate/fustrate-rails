class Fustrate.Components.Flash extends Fustrate.Components.Base
  @fadeInSpeed: 500
  @fadeOutSpeed: 2000
  @displayTime: 4000

  constructor: (message, { type, icon } = {}) ->
    message = "#{Fustrate.icon(icon)} #{message}" if icon

    bar = $ "<div class=\"flash #{type ? 'info'}\"></div>"
      .html message
      .hide()
      .prependTo $('#flashes')
      .fadeIn @constructor.fadeInSpeed
      .delay @constructor.displayTime
      .fadeOut @constructor.fadeOutSpeed, ->
        bar.remove()

  @initialize: ->
    $('body').append '<div id="flashes">'

  class @Error
    constructor: (message, { icon } = {}) ->
      new Fustrate.Components.Flash message, type: 'error', icon: icon

  class @Info
    constructor: (message, { icon } = {}) ->
      new Fustrate.Components.Flash message, type: 'info', icon: icon

  class @Success
    constructor: (message, { icon } = {}) ->
      new Fustrate.Components.Flash message, type: 'success', icon: icon
