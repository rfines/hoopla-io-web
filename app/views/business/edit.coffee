template = require 'templates/business/edit'
View = require 'views/base/view'
Business = require 'models/business'
AddressView = require 'views/address'


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

  events:
    'submit form' : 'save'

  save: (e) ->
    e.preventDefault()
    @model.set
      location : @subview('geoLocation').getLocation()
    @model.save {}, {
      success: =>
        @publishEvent '!router:route', 'myBusinesses'
    }