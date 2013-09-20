View = require 'views/base/view'
ImageUtils = require 'utils/imageUtils'
MediaList = require 'views/media/mediaLibraryPopover'
ImageChooser = require 'views/common/imageChooser'

module.exports = class InlineEdit extends View

  initialize: ->
    super()
    @isNew = @model.isNew()

  events:
    'click .saveButton' : 'save'
    'click .cancel':'cancel'
    'click .change-image-btn':'showImageControls'      

  getTemplateData: ->
    td = super
    td.isNew = @model.isNew()
    td.hasMedia = Chaplin.datastore.media.length > 0
    td.hasBusinesses = Chaplin.datastore.business.length > 0
    td.hasSingleBusiness = Chaplin.datastore.business.length is 1
    td.hasMultipleBusinesses = Chaplin.datastore.business.length > 1
    if @hasMedia
      td.imageUrl = @model.imageUrl({height: 163, width: 266}) if @model.imageUrl
      td.hideUpload = @model.imageUrl?
    td

  attach: ->
    super()
    @modelBinder.bind @model, @$el
    Backbone.Validation.bind(@)
    @$el.find(".select-chosen").chosen({width:'100%'})  
    @$el.find(".select-chosen-nosearch").chosen({width:'100%', disable_search: true})  
    if @hasMedia
      if @model.get('media')?.length > 0
        @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser'), data:{showControls:false,standAloneUpload:false}}))
      else
        @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser'), data:{showControls:true,standAloneUpload:false}}))
      @attachMediaLibrary() 
       
    if @model.get('media')?.length >0
      @$el.find('.image-controls').hide()
      @$el.find('.default-image-actions').show()
    else
      @$el.find('.default-image-actions').hide()
    if @isNew
      @$el.find('.change-image-btn').hide()


  validate: ->
    @$el.find('.has-error').removeClass('has-error')
    if @model.validate()
      for x in _.keys(@model.validate())
        console.log @$el.find("input[name=#{x}], textarea[name=#{x}]").parent()
        @$el.find("input[name=#{x}], textarea[name=#{x}]").parent().addClass('has-error')
      return false
    else
      return true    
  cancel: (e)=>
    e.preventDefault() if e
    if @subview("newItem").length > 0 && @model.isNew()
      @removeSubview("newItem")
      @$el.find('.newItem').scrollUp()
    else
      e.stopPropagation() if e
      @publishEvent "#{@noun}:#{@model.id}:edit:close"

  save: (e) ->
    e.preventDefault() 
    @updateModel()
    if @validate()
      if @hasMedia and $("#filelist div").length > 0
        @subview('imageChooser').uploadQueue (media) =>
          console.log media
          @model.set 
            'media': [media]
          @model.save {}, {
            success: =>
              @postSave() if @postSave
          }
      else
        @model.save {}, {
            success: =>
              @postSave() if @postSave
        }    


  postSave: =>
    @publishEvent 'stopWaiting'
    if @isNew
      @collection.add @model
      @publishEvent "#{@noun}:created", @model
      @dispose()
    else
      @publishEvent "#{@noun}:#{@model.id}:edit:close" 

  showImageControls: (e)=>
    e.preventDefault()
    @$el.find('.currentImage').hide()
    @$el.find('.image-controls').show()
    @$el.find('.default-image-actions').hide()          