template = require 'templates/event/edit'
View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'

module.exports = class EventEditView extends View
  autoRender: true
  className: 'event-edit'
  template: template

  initialize: ->
    console.log 'init'
    console.log @collection
    super
    @model = @model || new Event()

  attach: ->
    super
    @modelBinder.bind @model, @$el
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @$el.find(".select-chosen").chosen()
    $('.business').on 'change', (evt, params) =>
      @model.set 'business', params.selected
      console.log @model

  events:
    'submit form' : 'save'

  getTemplateData: ->
    td = super()
    td.businesses = Chaplin.datastore.business.models
    td    

  save: (e) ->
    e.preventDefault()
    @model.set
      location : @subview('geoLocation').getLocation()
    @model.save {}, {
      success: =>
        @publishEvent '!router:route', 'myEvents'
    }