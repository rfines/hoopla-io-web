ListItemView = require 'views/base/listItem'
template = require 'templates/business/listItem'

module.exports = class ListItem extends ListItemView
  template: template
  noun : "business"

  getTemplateData: ->
    td = super
    callbackUrl = "#{window.baseUrl}callbacks/facebook?businessId=#{@model.id}"
    td.facebookConnectUrl = "https://www.facebook.com/dialog/oauth?client_id=#{window.facebookClientId}&redirect_uri=#{encodeURIComponent(callbackUrl)}"
    td.twitterConnectUrl = "#{window.baseUrl}oauth/twitter?businessId=#{@model.id}"
    td.facebookConnected = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'FACEBOOK'
    td.twitterConnected = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'TWITTER'      
    td.imageUrl = @model.imageUrl({height: 163, width: 266})      
    td