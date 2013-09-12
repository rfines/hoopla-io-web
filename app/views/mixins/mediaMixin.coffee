ImageUtils = require 'utils/imageUtils'
MediaList = require 'views/media/mediaLibraryPopover'
ImageChooser = require 'views/common/imageChooser'

module.exports = class MediaMixin
  hasMedia : true
  
  constructor: (name) ->
    @name = 'MediaMixin'

  updateImage: (e) ->
    if e
      @model.set 'media', [e.toJSON()]
      @$el.find('.modal').modal('hide')
      @$el.find('.currentImage').attr('src', $.cloudinary.url(ImageUtils.getId(e.attributes.url), {crop: 'fill', height: 250, width: 350}))
      @$el.find('.imageChooser').hide()                        

  attachMediaLibrary: ->
    @removeSubview('mediaPopover') if @subview('mediaPopover')
    @subview('mediaPopover', new MediaList({container : @$el.find('.library-contents'), collection: Chaplin.datastore.media}))        