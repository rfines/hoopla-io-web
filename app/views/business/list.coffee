ListView = require 'views/base/editableList'
template = require 'templates/business/list'
ListItem = require 'views/business/listItem'
EditView = require 'views/business/edit'
Model = require 'models/business'
MessageArea = require 'views/messageArea'

module.exports = class List extends ListView
  className: 'business-list'
  template: template
  itemView: ListItem
  noun : 'business'
  listSelector: '.business-list-container'
  listRoute : 'myBusinesses'
  EditView : EditView
  Model : Model  

  attach:->
    super()
    @subscribeEvent 'closeOthers',=>
      @removeSubview 'newItem' if @subview 'newItem'
    baseUrl = window.location.href.split('?')[0].replace "#{window.baseUrl}", ""
    if @params?.error
      @publishEvent '!router:changeURL',  "#{baseUrl}"
      @publishEvent 'message:publish', 'error', @params.error
    else if @params?.success
      @publishEvent '!router:changeURL',  "#{baseUrl}"
      @publishEvent 'message:publish', 'success', @params.success  