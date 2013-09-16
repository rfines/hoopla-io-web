Controller = require 'controllers/base/postLoginController'
Businesses = require 'models/businesses'
PromotionTarget = require 'models/promotionTarget'

module.exports = class BusinessController extends Controller

  edit: (params) ->
    BusinessEdit = require 'views/business/edit'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new BusinessEdit
          region: 'main'
          collection : Chaplin.datastore.business
          model : Chaplin.datastore.business.get(params.id)
      error: (model, response) =>
        console.log 'error'
        console.log response   

  list: (params) ->
    BusinessList = require 'views/business/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new BusinessList
          region: 'main'
          collection : Chaplin.datastore.business
          params : params
      error: (model, response) =>
        console.log 'error'
        console.log response
  handleSuccess: (model,response,options)=>
    if response
      console.log response
    @publishEvent '!router:route', "myBusinesses?deauth=twitter_#{model}"

  handleFailure: (model,xhr,options)=>
    if response
      console.log xhr

  handleFBSuccess: (model,response,options)=>
    if response
      console.log response
    @publishEvent '!router:route', "myBusinesses?deauth=facebook_#{model}"

  handleFBFailure: (model,xhr,options)=>
    if response
      console.log xhr

  facebookDeauthorize:(params)->
    Chaplin.datastore.loadEssential 
      success: =>
        b = Chaplin.datastore.business.get(params.id)
        promos = b.get('promotionTargets')
        target = _.find promos, (item)=>
          return item.accountType is 'FACEBOOK'
        if target
          target = new PromotionTarget(target) 
          target.destroy({
            success: (model,response,options)=> 
              console.log "Success handler"
              @handleFBSuccess(params.id)
            error: (model,xhr,options)=>
              @handleFBFailure
          })
        else
          @publishEvent '!router:route', "myBusinesses"

      error: (model, response) =>
        console.log 'error'
        console.log response
         
  twitterDeauthorize:(params)->
    Chaplin.datastore.loadEssential 
      success: =>
        b = Chaplin.datastore.business.get(params.id)
        promos = b.get('promotionTargets')
        target = _.find promos, (item)=>
          return item.accountType is 'TWITTER'
        if target
          target = new PromotionTarget(target) 
          target.destroy({
            success:(model,response,options)=> 
              console.log "Success"
              @handleSuccess(params.id)
            error:(model,xhr,options)->
              @handleFailure
          })
          
        else
          @publishEvent '!router:route', "myBusinesses"

      error: (model, response) =>
        console.log 'error'
        console.log response 
