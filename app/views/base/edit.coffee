View = require 'views/base/view'
ImageUtils = require 'utils/imageUtils'
MediaList = require 'views/media/mediaLibraryPopover'
ImageChooser = require 'views/common/imageChooser'
ImageUtils = require 'utils/imageUtils'

module.exports = class Edit extends View
  className: ''

  events:
    'click .saveButton' : 'save'
    'click .cancel':'cancel'      

  getTemplateData: ->
    td = super()
    td.isNew = @model.isNew()
    td.imageUrl = @model.imageUrl({height: 163, width: 266}) if @model.imageUrl
    td

  attach: ->
    super
    @modelBinder.bind @model, @$el
    @$el.find(".select-chosen").chosen({width:'100%'})
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
    @attachMediaLibrary()    

  updateImage: (e) =>
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

  validate: ->
    @$el.find('.has-error').removeClass('has-error')
    errors = @model.validate()
    console.log errors
    if errors
      for x in errors
        @$el.find("textarea[name='#{x.p}'], input[name='#{x.p}']").parent().addClass('has-error')
      return false
    else
      return true

  save: (e) ->
    e.preventDefault() 
    @updateModel()
    console.log @validate()
    if @validate()
      console.log 'past validate'
      if $("#filelist div").length > 0
        @subview('imageChooser').uploadQueue (media) =>
          @model.set 'media',[media]
          @model.save {}, {
            success: =>
              @postSave() if @postSave
            error: (model, response) ->
              console.log response
          }
      else
        @model.save {}, {
            success: =>
              console.log 'model save success'
              console.log @postSave
              @postSave() if @postSave
            error: (model, response) ->
              console.log response
        }    

  postSave: =>
    @collection.add @model
    @publishEvent '!router:route', @listRoute  
