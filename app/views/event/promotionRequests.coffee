ListView = require 'views/base/list'
template = require 'templates/event/promotionRequests'
ListItem = require 'views/event/promotionRequest'
Event = require 'models/event'


module.exports = class PromotionRequestList extends ListView
  className: 'promotion-request-list'
  template: template
  itemView: ListItem
  noun : 'promotionRequest'
  listSelector : '.promotions-container'
  type=""
  past = false
  initialze:(options)=>
    super(options)
    console.log options
    if options.type
      @type=options.type
    if options.past
      @past = options.past
  attach:()=>
    super
  getTemplateData:()=>
    td = super()
    td.posts = true
    td