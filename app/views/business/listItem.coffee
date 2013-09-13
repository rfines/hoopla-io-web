EditableListItem = require 'views/base/editableListItem'
template = require 'templates/business/listItem'
EditView = require 'views/business/edit'

module.exports = class ListItem extends EditableListItem
  template: template
  noun : "business"
  EditView : EditView

  getTemplateData: ->
    td = super
    callbackUrl = "#{window.baseUrl}callbacks/facebook?businessId=#{@model.id}"
    td.facebookConnectUrl = "https://www.facebook.com/dialog/oauth?client_id=#{window.facebookClientId}&scope=publish_actions,user_events,manage_pages,publish_stream,photo_upload,create_event&redirect_uri=#{encodeURIComponent(callbackUrl)}"
    td.twitterConnectUrl = "#{window.baseUrl}oauth/twitter?businessId=#{@model.id}"
    td.facebookConnected = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'FACEBOOK'
    td.twitterConnected = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'TWITTER'      
    td.imageUrl = @model.imageUrl({height: 163, width: 266, crop: 'fit'})      
    td
