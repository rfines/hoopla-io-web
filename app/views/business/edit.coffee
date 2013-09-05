template = require 'templates/business/edit'
View = require 'views/base/edit'
Business = require 'models/business'
AddressView = require 'views/address'
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
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    links = @model.get('socialMediaLinks')
    if links?.length > 0
      @$el.find('.facebook').val(_.findWhere(links, {target:"Facebook"})?.url)
      @$el.find('.twitter').val( _.findWhere(links, {target:"Twitter"})?.url)
      @$el.find('.foursquare').val(_.findWhere(links, {target:"Foursquare"})?.url)
    @subscribeEvent 'selectedMedia', @updateImage


  getTemplateData: ->
    td = super()
    td.imageUrl = @model.imageUrl({height: 163, width: 266})
    td    

  save: (e) ->
    e.preventDefault()
    @setSmLinks()
    @setLocation()
    if $("#filelist div").length > 0
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
    @publishEvent '!router:route', 'myBusinesses'

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