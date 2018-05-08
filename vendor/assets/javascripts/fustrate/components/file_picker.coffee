class Fustrate.Components.FilePicker extends Fustrate.Components.Base
  constructor: (callback) ->
    input = document.createElement 'input'
    input.setAttribute 'type', 'file'

    input.addEventListener 'change', ->
      callback input.files

      input.parentNode.removeChild input

    document.body.appendChild(input)

    input.click()
