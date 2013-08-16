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
      address: 
        line1: @$el.find('.address1').val()
        line2: @$el.find('.address2').val()
        city: @$el.find('.city').val()
        state_province: @$el.find('.state').val()
        postal_code: @$el.find('.postalCode').val()
      geo :
        "type" : "Point"
        "coordinates" : [-94.58267601970849,39.11036]        
    @model.save()