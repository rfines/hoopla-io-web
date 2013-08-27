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
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
    super 

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