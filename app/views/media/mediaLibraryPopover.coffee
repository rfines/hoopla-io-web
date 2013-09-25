template = require 'templates/common/imageLibraryList'
CollectionView = require 'views/media/list'
imageLibraryItem = require 'views/media/mediaLibraryPopoverItem'

module.exports = class mediaLibraryList extends CollectionView
  className: 'selections'
  template: template
  itemView: imageLibraryItem
  