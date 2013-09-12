ListView = require 'views/base/list'
template = require 'templates/media/list'
ListItem = require 'views/media/listItem'
ImageChooser = require 'views/common/imageChooser'

module.exports = class List extends ListView
  className: 'chooser'
  template: template
  itemView: ListItem
  noun : 'media'
  standAloneUpload :false
  initialize: (options)->
    super(options)
    @standAloneUpload = options.standAloneUpload

  attach: ->
    super()
    if @standAloneUpload
      @subview('imageChooser', new ImageChooser({container: @$el.find('.well.add-media'), standAloneUpload:true}))

  