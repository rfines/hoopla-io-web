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
    td.facebookConnected = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'FACEBOOK' 
    td.twitterConnected = _.some @model.get('promotionTargets'), (item) ->
      item.accountType is 'TWITTER'      
    td.imageUrl = @model.imageUrl({height: 163, width: 266, crop: 'fit'})      
    td
  events: 
    "click #deauth-facebook": "deauthorizeFacebook"
    "click #deauth-twitter":"deauthorizeTwitter"
    "click .twitter.socialNotConnected":"redirectToTwitter"

  attach: ->
    super()
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
          @publishEvent "message:publish", 'success',"Disconnected Facebook from #{@model.get('name')}"
        error: (model,xhr,options)=>
          @publishEvent "message:publish", 'error','An error occurred while disconnecting this Facebook account.'
      })
    else
      @publishEvent "message:publish", 'error','An error occurred while disconnecting this Facebook account.'

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
          @publishEvent "message:publish", 'success',"Disconnected Twitter from #{@model.get('name')}"
        error: (model,xhr,options)=>
          @publishEvent "message:publish", 'error','An error occurred while disconnecting this Twitter account.'
      })
    else
      @showTwitterAuthBtn()
      @publishEvent "message:publish", 'success',"Disconnected Twitter from #{@model.get('name')}."

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
  redirectToTwitter:(e)=>
    e.preventDefault() if e
    window.location.href = "/oauth/twitter?businessId=#{@model.id}"