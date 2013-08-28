template = require 'templates/business/edit'
View = require 'views/base/view'
Business = require 'models/business'
AddressView = require 'views/address'
ImageChooser = require 'views/common/imageChooser'
module.exports = class BusinessEditView extends View
  autoRender: true
  className: 'users-list'
  template: template

  initialize: ->
    super
    @model = @model || new Business()
    console.log @model

  attach: ->
    super
    @modelBinder.bind @model, @$el
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
     

  events:
    'submit form' : 'save'

  getTemplateData: ->
    td = super()
    media = @model.get('media')
    if media?.length > 0
      td.mediaUrl = media[0].url
    td    

  save: (e) ->
    e.preventDefault()
    @model.set
      location : @subview('geoLocation').getLocation()

    if @model.get('media') and @subview('imageChooser').getMedia()
      @model.get('media').push @subview('imageChooser').getMedia()
    else if @subview('imageChooser').getMedia()
      @model.set 'media',[@subview('imageChooser').getMedia()]

    console.log @model.get 'media'
    if @model.get('contacts') and (@$el.find('.email') or @$el.find('.phone'))
      @model.get('contacts').push {email:@$el.find('.email').val(), phone:@$el.find('.phone').val()}
    else
      @model.set 'contacts', [{email:@$el.find('.email').val(), phone:@$el.find('.phone').val()}]
    
    fb = @$el.find('facebook').val()
    tw = @$el.find('twitter').val()
    fq = @$el.find('foursquare').val()
    if @model.get('socialMediaLinks')
      if fb
        @model.get('socialMediaLinks').push {target:'Facebook', url:fb}
      if tw
        @model.get('socialMediaLinks').push {target:'Twitter', url:tw}
      if fq
        @model.get('socialMediaLinks').push {target:'Foursquare', url:fq}
    else
      if fb
        @model.set 'socialMediaLinks', {target:'Facebook', url:fb}
      if tw
        @model.set 'socialMediaLinks', {target:'Twitter', url:tw}
      if fq
        @model.set 'socialMediaLinks', {target:'Foursquare', url:fq}

    @model.save {}, {
      success: =>
        Chaplin.datastore.business.add @model
        @publishEvent '!router:route', 'myBusinesses'
      error: (model, response) ->
        console.log model
        console.log response
        console.log "Error saving"
    }