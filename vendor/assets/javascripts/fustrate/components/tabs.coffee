class Fustrate.Components.Tabs extends Fustrate.Components.Base
  constructor: (@tabs) ->
    @tabs.on 'click', 'li > a', (e) =>
      e.preventDefault()

      @activateTab $(e.currentTarget)

    if window.location.hash
      @activateTab $("li > a[href='#{window.location.hash}']", @tabs).first()
    else if $('li > a.active', @tabs).length > 0
      @activateTab $('li > a.active', @tabs).first()
    else
      @activateTab $('li > a', @tabs).first()

  activateTab: (tab) =>
    return unless tab

    $('.active', @tabs).removeClass 'active'
    tab.addClass 'active'

    $("##{tab.attr('href').split('#')[1]}")
      .addClass 'active'
      .siblings()
      .removeClass 'active'

  @initialize: =>
    $('ul.tabs').each (index, elem) =>
      new @($ elem)
