View = require 'views/base/view'
Event = require 'models/event'
AddressView = require 'views/address'

module.exports = class CreateFacebookEventView extends View
  model:Event
  template: require 'templates/event/createFacebookEvent'
  autoRender: true
  className: 'create-facebook-event'
  business = {}
  promotionTarget = {}
  promotionRequest = {}
  initialize:(options)->
    super(options)
    console.log options
    @business = options.options.business
    @promotionTarget = options.options.promotionTarget
  getTemplateData: ()->
    td = super()
    td.profileImgUrl = @promotionTarget.profileImageUrl
    td.profileName = @promotionTarget.profileName
    td.eventAddress = @model.attributes.location.address
    td.coverPhoto = @promotionTarget.profileCoverPhoto
    td
  attach:()->
    super()
    @subview('event-address', new AddressView({container : @$el.find('.event-map'), model : @model}))  
    $('input.address').remove()
    $('label[for=address]').remove()
