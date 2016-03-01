class Fustrate.Components.Disclosure extends Fustrate.Components.Base
  @initialize: ->
    $('body').on 'click', '.disclosure-title', (event) ->
      disclosure = $(event.currentTarget).closest('.disclosure')

      isOpen = disclosure.hasClass 'open'

      disclosure
        .toggleClass 'open'
        .trigger "#{if isOpen then 'closed' else 'opened'}.disclosure"

      false
