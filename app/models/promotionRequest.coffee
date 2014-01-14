Model = require 'models/base/model'

module.exports = class PromotionRequest extends Model
  url:()->
    console.log @isNew()
    if @isNew()
      "/api/event/#{@eventId}/promotionRequest"
    else
      "/api/promotionRequest/#{@id}"