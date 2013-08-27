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

  attach: ->
    super
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
     

  events:
    'submit form' : 'save'

  save: (e) ->
    e.preventDefault()
    @model.set
      location : @subview('geoLocation').getLocation()
    if @model.media
      @model.media.push ImageChooser.getMedia
    else
      @model.media = []
      @model.media.push ImageChooser.getMedia
    @model.save {}, {
      success: =>
        @publishEvent '!router:route', 'myBusinesses'
    }