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
    @model = new Business()

  attach: ->
    super
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))


  events:
    'submit form' : 'save'

  save: (e) ->
    e.preventDefault()
    console.log 'save'
    @model.set
      name : @$el.find('.name').val()
      description : @$el.find('.description').val()
      location : @subview('geoLocation').getLocation()
    console.log @model.attributes
    @model.save()