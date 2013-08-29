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
    links = @model.get('socialMediaLinks')
    if links?.length > 0
      @$el.find('.facebook').val(_.findWhere(links, {target:"Facebook"}).url)
      @$el.find('.twitter').val( _.findWhere(links, {target:"Twitter"}).url)
      @$el.find('.foursquare').val(_.findWhere(links, {target:"Foursquare"}).url)

  events:
    'submit form' : 'save'
    'click button.cancel':'cancel'

  getTemplateData: ->
    td = super()
    media = @model.get('media')
    if media?.length > 0
      td.imageUrl = $.cloudinary.url(ImageUtils.getId(media[0].url), {crop: 'fill', height: 163, width: 266})
    td    

  save: (e) ->
    e.preventDefault()
    if @model.get('media') and @subview('imageChooser').getMedia()
      @model.get('media').push @subview('imageChooser').getMedia()
    else if @subview('imageChooser').getMedia()
      @model.set 'media',[@subview('imageChooser').getMedia()]
    fb = @$el.find('.facebook').val()
    tw = @$el.find('.twitter').val()
    fq = @$el.find('.foursquare').val()
    if @model.get('socialMediaLinks')
      links = @model.get('socialMediaLinks')
      if fb
        f = _.findWhere(links, {url:fb})
        if not f
          @model.get('socialMediaLinks').push {target:'Facebook', url:fb}
      if tw
        t= _.findWhere(links, {url:tw})
        if not t
          @model.get('socialMediaLinks').push {target:'Twitter', url:tw}
      if fq
        q = _.findWhere(links, {url:fq})
        if not q
          @model.get('socialMediaLinks').push {target:'Foursquare', url:fq}
    else
      @model.set 'socialMediaLinks', []
      if fb
        @model.get('socialMediaLinks').push {target:'Facebook', url:fb}
      if tw
        @model.get('socialMediaLinks').push {target:'Twitter', url:tw}
      if fq
        @model.get('socialMediaLinks').push {target:'Foursquare', url:fq}
    @model.set
      location : @subview('geoLocation').getLocation()
    @model.save {}, {
      success: =>
        Chaplin.datastore.business.add @model
        @publishEvent '!router:route', 'myBusinesses'
      error: (model, response) ->
        console.log model
        console.log response
        console.log "Error saving"
    }
  cancel:()->
    window.location = '/myBusinesses'