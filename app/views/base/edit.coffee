View = require 'views/base/inlineEdit'
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
    td.imageUrl = @model.imageUrl({height: 163, width: 266}) if @model.imageUrl
    td.hideUpload = @model.imageUrl?
    td

  attach: ->
    super
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

  validate: ->
    @$el.find('.has-error').removeClass('has-error')
    if @model.validate()
      for x in _.keys(@model.validate())
        console.log x
        @$el.find("input[name='#{x}'], textarea[name=#{x}]").parent().addClass('has-error')
      return false
    else
      return true

  save: (e) ->
    e.preventDefault() 
    @updateModel()
    if @validate()
      console.log 'inside validate'
      if $("#filelist div").length > 0
        @subview('imageChooser').uploadQueue (media) =>
          @model.set 
            'media': [media]
          @model.save {}, {
            success: =>
              console.log 'saved'
              @postSave() if @postSave
          }
      else
        @model.save {}, {
            success: =>
              console.log 'saved'
              @postSave() if @postSave
        }    
