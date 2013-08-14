Collection = require 'models/base/collection'
PromotionTarget = require('models/promotionTarget')

module.exports = class PromotionTargets extends Collection
  Model : PromotionTarget
  url: "#{window.apiUrl}promotionTarget"
  
