Model = require 'models/base/model'

module.exports = class PromotionRequest extends Model
  url:()->
    if @isNew()
      "/api/event/#{@eventId}/promotionRequest"
    else
      "/api/promotionRequest/#{@id}"