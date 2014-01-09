Collection = require 'models/base/collection'
PromotionRequest = require('models/promotionRequest')

module.exports = class PromotionRequests extends Collection
  model : PromotionRequest
  eventId:undefined
  url: ()=>
    "#{window.baseUrl}api/event/#{@eventId}/promotionRequests"
  byType: (push_type) =>
    filtered = @filter((pr) =>
      pr.get("pushType") is push_type
    )
    new PromotionRequests(filtered)
  past:(date_check) =>
    filtered = @filter((pr)=>
      moment(pr.get('promotionTime')).isBefore(moment(date_check))
    )
    new PromotionRequests(filtered)
  future:(date_check)=>
    filtered = @filter((pr)=>
      moment(pr.get('promotionTime')).isAfter(moment(date_check))
    )
    new PromotionRequests(filtered)
