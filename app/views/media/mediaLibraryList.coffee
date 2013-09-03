template = require 'templates/media/list'
CollectionView = require 'views/base/collection-view'
MediaListItem = require 'views/media/mediaLibraryListItem'
ImageChooser = require 'views/common/imageChooser'

module.exports = class mediaLibraryList extends CollectionView
  autoRender: true
  renderItems: true
  className: 'chooser'
  template: template
  itemView: MediaListItem

  initialize: ->
    super
  attach: ->
    super
    @subview('imageChooser', new ImageChooser({container: @$el.find('.add-media')}))

  