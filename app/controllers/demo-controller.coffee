Controller = require 'controllers/base/AuthenticatedController'
PromotionTargetsList = require 'views/users-list-view'
PromotionTargets = require 'models/promotionTargets'
Businesses = require 'models/businesses'


module.exports = class BusinessController extends Controller
  promotionTargets: ->
    @collection = new PromotionTargets()
    @collection.fetch
      success: =>
        console.log @collection.models
      error: (model, response) =>
        console.log 'error'
        console.log response
    
  createBusiness: ->
    BusinessEdit = require 'views/business/edit'
    console.log 'create business'
    @collection = new Businesses()
    @collection.fetch
      success: =>
        @view = new BusinessEdit
          region: 'main'
          collection : @collection
      error: (model, response) =>
        console.log 'error'
        console.log response

  businessDashboard: ->
    BusinessList = require 'views/business/list'
    console.log 'business dashboard'
    @collection = new Businesses()
    @collection.fetch
      success: =>
        @view = new BusinessList
          region: 'main'
          collection : @collection
      error: (model, response) =>
        console.log 'error'
        console.log response