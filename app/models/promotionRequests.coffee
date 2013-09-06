Collection = require 'models/base/collection'
PromotionRequest = require('models/promotionRequest')

module.exports = class PromotionRequests extends Collection
  model : PromotionRequest
  url: "#{window.apiUrl}promotionRequest"
