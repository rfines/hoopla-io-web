View = require 'views/base/view'
ImageUtils = require 'utils/imageUtils'
MediaList = require 'views/media/mediaLibraryPopover'
ImageChooser = require 'views/common/imageChooser'
AddressView = require 'views/address'
module.exports = class InlineEdit extends View
  saving=false
  description = ""
  editor = undefined
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
    @$el.find('.helpTip').tooltip()
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
    if @$el.find('.geoLocation').length >0
      setTimeout(()=>
        @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
      , 100)
    if @$el.find('#description-textarea').length >0
      wysihtml5ParserRules = tags:
        strong: { "rename_tag": "b" }
        b: 1
        i: 1
        em: 1
        br:1
        p:1
        div: 1
        span: 1
        ul: 1
        li: 1

      @editor = new wysihtml5.Editor("description-textarea",
        toolbar: "toolbar"
        parserRules: wysihtml5ParserRules
        autoLink:false
        placeholderText: 'Description'
        cleanUp:true
      )

      
  validate: ->
    @$el.find('.has-error').removeClass('has-error')
    if @model.validate()
      for x in _.keys(@model.validate())
        if x is 'description'
          $('.description-container').addClass('has-error')
        else
          @$el.find("input[name=#{x}], textarea[name=#{x}]").parent().addClass('has-error')
      return false
    else
      return true 
  partialValidate:() ->
    @$el.find('.has-error').removeClass('has-error')
    isValid = true
    console.log
    if @model.validate()
      for x in _.keys(@model.validate())
        if x is 'description' and $('.description-container').is(':visible')
          $('.description-container').addClass('has-error')
          isValid = false
        else if x is 'location'
          $(".business-container, .host-container").addClass('has-error')
          isValid = false
          console.log "location"
          console.log @model
        else
          el= @$el.find("input[name=#{x}], textarea[name=#{x}]")
          if el.parent().is(":visible") is true
            @$el.find("input[name=#{x}], textarea[name=#{x}]").parent().addClass('has-error')
            isValid = false
      if $('.startDate').is(':visible')
        v = $('.startDate').val()
        if not v or v.length is 0
          $('.startDate').parent().addClass('has-error')
          isValid = false
      if $('.startTime').is(':visible')
        v = $('.startTime').val()
        if not v
          $('.startTime').parent().addClass('has-error')
          isValid= false

      return isValid
    else
      return isValid   
  
  cancel: (e)=>
    e.preventDefault() if e
    if @model.isNew
      @dispose()
      $("html, body").animate({ scrollTop: 0 }, "slow");
      @publishEvent "closeOthers"
    else
      @publishEvent "#{@noun}:#{@model.id}:edit:close"

  save: (e) ->
    e.preventDefault() 
    @updateModel()
    console.log @validate()
    console.log @model
    if @validate() and not saving
      saving = true
      if @hasMedia and $("#filelist div").length > 0
        @subview('imageChooser').uploadQueue (media) =>
          @model.set 
            'media': [media]
          @model.save {}, {
            success: =>
              saving = false
              @postSave() if @postSave
          }
      else
        @model.save {}, {
            success: =>
              saving = false
              @postSave() if @postSave
        }    


  postSave: =>
    @publishEvent 'stopWaiting'
    $("html, body").animate({ scrollTop: 0 }, "slow");
    if @isNew
      tracking = {"email" : Chaplin.datastore.user.get('email')}
      tracking["#{@noun}-name"] = @model.get('name')
      @publishEvent 'trackEvent', "create-#{@noun}", tracking    
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