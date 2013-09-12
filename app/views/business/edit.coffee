template = require 'templates/business/edit'
View = require 'views/base/edit'
Business = require 'models/business'
AddressView = require 'views/address'
ImageUtils = require 'utils/imageUtils'

module.exports = class BusinessEditView extends View
  autoRender: true
  className: 'business-edit'
  template: template
  listRoute: 'myBusinesses'
  noun : 'business'

  attach: ->
    super
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    links = @model.get('socialMediaLinks')
    if links?.length > 0
      @$el.find('.facebook').val(_.findWhere(links, {target:"Facebook"})?.url)
      @$el.find('.twitter').val( _.findWhere(links, {target:"Twitter"})?.url)
      @$el.find('.foursquare').val(_.findWhere(links, {target:"Foursquare"})?.url)
    @subscribeEvent 'selectedMedia', @updateImage

  updateModel: ->
    @setSmLinks()
    @setLocation()

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