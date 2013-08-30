ListView = require 'views/base/list'
template = require 'templates/media/list'
ListItem = require 'views/media/listItem'
ImageChooser = require 'views/common/imageChooser'

module.exports = class List extends ListView
  className: 'chooser'
  template: template
  itemView: ListItem
  noun : 'media'

  attach: ->
    super
    @subview('imageChooser', new ImageChooser({container: @$el.find('.add-media')}))  

  