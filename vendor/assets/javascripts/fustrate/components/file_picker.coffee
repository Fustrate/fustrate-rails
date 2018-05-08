class Fustrate.Components.FilePicker extends Fustrate.Components.Base
  constructor: (callback) ->
    input = document.createElement 'input'
    input.setAttribute 'type', 'file'

    input.addEventListener 'change', ->
      callback input.files

      input.parentNode.removeChild input

    document.body.appendChild(input)

    event = document.createEvent 'HTMLEvents'
    event.initEvent 'click', true, false

    input.dispatchEvent event
