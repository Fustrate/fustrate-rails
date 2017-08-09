class Fustrate.Components.Tabs extends Fustrate.Components.Base
  constructor: (@tabs) ->
    @tabs.on 'click', 'li > a', (e) =>
      @activateTab $(e.currentTarget), true

      false

    if window.location.hash
      @activateTab $("li > a[href='#{window.location.hash}']", @tabs).first(), false
    else if $('li > a.active', @tabs).length > 0
      @activateTab $('li > a.active', @tabs).first(), false
    else
      @activateTab $('li > a', @tabs).first(), false

  activateTab: (tab, changeHash) =>
    return unless tab.length > 0

    $('.active', @tabs).removeClass 'active'
    tab.addClass 'active'
    hash = tab.attr('href').split('#')[1]
    
    window.location.hash = hash if changeHash
    
    $("##{hash}")
      .addClass 'active'
      .siblings()
      .removeClass 'active'

  @initialize: =>
    $('ul.tabs').each (index, elem) =>
      new @($ elem)
