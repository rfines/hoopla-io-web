template = require 'templates/business/edit'
View = require 'views/base/view'
Business = require 'models/business'
AddressView = require 'views/address'
ImageChooser = require 'views/common/imageChooser'
MediaList = require 'views/media/mediaLibraryPopover'
ImageUtils = require 'utils/imageUtils'

module.exports = class BusinessEditView extends View
  autoRender: true
  className: 'users-list'
  template: template

  initialize: ->
    super
    @model = @model || new Business()

  attach: ->
    super
    @modelBinder.bind @model, @$el
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
    @attachMediaLibrary()
    links = @model.get('socialMediaLinks')
    if links?.length > 0
      @$el.find('.facebook').val(_.findWhere(links, {target:"Facebook"})?.url)
      @$el.find('.twitter').val( _.findWhere(links, {target:"Twitter"})?.url)
      @$el.find('.foursquare').val(_.findWhere(links, {target:"Foursquare"})?.url)
    @subscribeEvent 'selectedMedia', (e)=>
      if e
        @model.set 'media', [e.toJSON()]
        @$el.find('.modal').modal('hide')
        @$el.find('.currentImage')[0].attributes.src = e.attributes.url
        @$el.find('.currentImage')[0].remove()
        newUrl = $.cloudinary.url(ImageUtils.getId(e.attributes.url), {crop: 'fill', height: 250, width: 350})
        @$el.find('.profileImage').append("<img src=#{newUrl} class='currentImage' />")
        @$el.find('.imageChooser').hide()      

  events:
    'submit form' : 'save'
    'click button.cancel':'cancel'


  getTemplateData: ->
    td = super()
    td.imageUrl = @model.imageUrl({height: 163, width: 266})
    td    

  save: (e) ->
    e.preventDefault()
    @setSmLinks()
    @setLocation()
    if $("#filelist div").length > 0
      console.log "Here I am"
      @subview('imageChooser').uploadQueue (media) =>
        @model.set 'media',[media]
        @model.save {}, {
          success: =>
            Chaplin.datastore.business.add @model
            @publishEvent '!router:route', 'myBusinesses'
          error: (model, response) ->
            console.log response
        }
    else
      @model.save {}, {
          success: =>
            Chaplin.datastore.business.add @model
            @publishEvent '!router:route', 'myBusinesses'
          error: (model, response) ->
            console.log response
      }
      
  cancel:()->
    window.location = '/myBusinesses'

  attachMediaLibrary: ()->
    @removeSubview('mediaPopover') if @subview('mediaPopover')
    @subview('mediaPopover', new MediaList({container : @$el.find('.library-contents'), collection: Chaplin.datastore.media}))

  setLocation: ()->
    @model.set
        location : @subview('geoLocation').getLocation()

  setSmLinks: ()->
    fb = @$el.find('.facebook').val()
    tw = @$el.find('.twitter').val()
    fq = @$el.find('.foursquare').val()
    @model.addFacebookLink(fb)
    @model.addTwitterLink(tw)
    @model.addFoursquareLink(fq)