class Fustrate.Components.DropZone extends Fustrate.Components.Base
  constructor: (target, callback) ->
    $(target)
      .off '.drop_zone'
      .on 'dragover.drop_zone dragenter.drop_zone', false
      .on 'drop.drop_zone', (event) ->
        callback event.originalEvent.dataTransfer.files

        false
