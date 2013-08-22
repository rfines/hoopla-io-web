Controller = require 'controllers/base/AuthenticatedController'
PromotionTargetsList = require 'views/users-list-view'
PromotionTargets = require 'models/promotionTargets'
Businesses = require 'models/businesses'
BusinessEdit = require 'views/business/edit'
RegisterUserView = require 'views/user-register-view'
ChangePasswordView = require 'views/change-password-view'
User = require 'models/user'

module.exports = class DemoController extends Controller
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

  editBusiness: (params) ->
    console.log 'edit business'
    BusinessEdit = require 'views/business/edit'
    console.log 'create business'
    @collection = new Businesses()
    @collection.fetch
      success: =>
        @view = new BusinessEdit
          region: 'main'
          collection : @collection
          model : @collection.get(params.id)
      error: (model, response) =>
        console.log 'error'
        console.log response        

  createEvent: ->
    EventEdit = require 'views/event/edit'
    Events = require 'models/events'
    Chaplin.datastore.businesses = new Businesses()
    Chaplin.datastore.businesses.fetch
      success: =>
        @collection = new Events()    
        @collection.fetch
          success: =>
            @view = new EventEdit
              region: 'main'
              collection : @collection
          error: (model, response) =>
            console.log 'error'
            console.log response        

  registerUser: ->
    @view = new RegisterUserView  region:'main'
  changePassword: ->
    @view = new ChangePasswordView region:'main'
  
  businessDashboard: ->
    BusinessList = require 'views/business/list'
    @collection = new Businesses()
    @collection.fetch
      success: =>
        @view = new BusinessList
          region: 'main'
          collection : @collection
      error: (model, response) =>
        console.log 'error'
        console.log response

  eventDashboard: ->
    EventList = require 'views/event/list'
    Events = require 'models/events'
    @collection = new Events()
    @collection.fetch
      success: =>
        @view = new EventList
          region: 'main'
          collection : @collection
      error: (model, response) =>
        console.log 'error'
        console.log response