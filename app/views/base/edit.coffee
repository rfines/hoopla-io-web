View = require 'views/base/view'
ImageUtils = require 'utils/imageUtils'
MediaList = require 'views/media/mediaLibraryPopover'
ImageChooser = require 'views/common/imageChooser'
ImageUtils = require 'utils/imageUtils'

module.exports = class Edit extends View
  autoRender: true
  className: ''

  events:
    'click .saveButton' : 'save'
    'click .cancel':'cancel'      

  attach: ->
    super
    @modelBinder.bind @model, @$el
    @$el.find(".select-chosen").chosen({width:'100%'})
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
    @attachMediaLibrary()    

  updateImage: (e) =>
    console.log 'updateImage'
    console.log e
    if e
      @model.set 'media', [e.toJSON()]
      @$el.find('.modal').modal('hide')
      @$el.find('.currentImage').attr('src', $.cloudinary.url(ImageUtils.getId(e.attributes.url), {crop: 'fill', height: 250, width: 350}))
      @$el.find('.imageChooser').hide()             

  attachMediaLibrary: ->
    @removeSubview('mediaPopover') if @subview('mediaPopover')
    @subview('mediaPopover', new MediaList({container : @$el.find('.library-contents'), collection: Chaplin.datastore.media}))    

  cancel:()->
    @publishEvent '!router:route', @listRoute

  save: (e) ->
    console.log 'in save'
    e.preventDefault()  
    @updateModel()
    if $("#filelist div").length > 0
      @subview('imageChooser').uploadQueue (media) =>
        @model.set 'media',[media]
        @model.save {}, {
          success: =>
            @collection.add @model
            @publishEvent '!router:route', @listRoute
          error: (model, response) ->
            console.log response
        }
    else
      @model.save {}, {
          success: =>
            @collection.add @model
            @publishEvent '!router:route', @listRoute
          error: (model, response) ->
            console.log response
      }    