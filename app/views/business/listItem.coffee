EditableListItem = require 'views/base/editableListItem'
template = require 'templates/business/listItem'
EditView = require 'views/business/edit'
PromotionTarget = require 'models/promotionTarget'

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
  events: 
    "click #deauth-facebook": "deauthorizeFacebook"
    "click #deauth-twitter":"deauthorizeTwitter"

  attach: ->
    fbCon = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'FACEBOOK'
    twCon = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'TWITTER'
    if fbCon
      @showFbDisconnect()
    else
      @showFbAuthBtn()
    if twCon
      @showTwitterDisconnect()
    else
      @showTwitterAuthBtn()
    
  deauthorizeFacebook :(e)->
    e.preventDefault()
    promos = @model.get('promotionTargets')
    target = _.find promos, (item)=>
      return item.accountType is 'FACEBOOK'
    if target
      target = new PromotionTarget(target) 
      target.destroy({
        success: (model,response,options)=>      
          @showFbAuthBtn()
          console.log "publishing event"
          @publishEvent "message:publish", 'success',"Deauthorized Facebook from #{@model.get('name')}"
        error: (model,xhr,options)=>
          @publishEvent "message:publish", 'error','An error occurred while deauthorizing this Facebook account.'
      })
    else
      @publishEvent "message:publish", 'error','An error occurred while deauthorizing this Facebook account.'

  deauthorizeTwitter :(e)->
    e.preventDefault()
    promos = @model.get('promotionTargets')
    target = _.find promos, (item)=>
      return item.accountType is 'TWITTER'
    if target
      target = new PromotionTarget(target) 
      target.destroy({
        success: (model,response,options)=> 
          @showTwitterAuthBtn()
          console.log repsonse
          console.log "Publishing event"
          @publishEvent "message:publish", 'success',"Deauthorized Twitter from #{@model.get('name')}"
        error: (model,xhr,options)=>
          @publishEvent "message:publish", 'error','An error occurred while deauthorizing this Twitter account.'
      })
    else
      @showTwitterAuthBtn()
      @publishEvent "message:publish", 'success',"Deauthorized Twitter from #{@model.get('name')}."

  showFbAuthBtn:()=>
    @$el.find('.fb-auth').hide()
    @$el.find('.fb-not-auth').show()
  showFbDisconnect: ()=>
    @$el.find('.fb-auth').show()
    @$el.find('.fb-not-auth').hide()
  showTwitterAuthBtn:()=>
    @$el.find('.tw-auth').hide()
    @$el.find('.tw-not-auth').show()
  showTwitterDisconnect:()=>
    @$el.find('.tw-auth').show()
    @$el.find('.tw-not-auth').hide()