Model = require 'models/base/model'

module.exports = class PromotionRequest extends Model
  url:()->
    "/api/event/#{@eventId}/promotionRequest"