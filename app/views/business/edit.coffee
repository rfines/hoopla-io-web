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
    @modelBinder.bind @model, @$el
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))
    @subview('imageChooser', new ImageChooser({container: @$el.find('.imageChooser')}))
     

  events:
    'submit form' : 'save'

  getTemplateData: ->
    td = super()
    console.log @model.get('media')
    td.mediaUrl = @model.get('media')[0].url
    td    

  save: (e) ->
    e.preventDefault()
    console.log @subview('imageChooser').getMedia()._id
    @model.set
      location : @subview('geoLocation').getLocation()
    if @model.get('media')
      @model.get('media').push @subview('imageChooser').getMedia()._id
    else
      @model.set 'media',[@subview('imageChooser').getMedia()._id]

    @model.save {}, {
      success: =>
        console.log "Saving business"
        Chaplin.datastore.business.add @model
        @publishEvent '!router:route', 'myBusinesses'
      error: ->
        console.log "Error saving"
    }