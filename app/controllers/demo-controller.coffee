Controller = require 'controllers/base/AuthenticatedController'
PromotionTargetsList = require 'views/users-list-view'
PromotionTargets = require 'models/promotionTargets'
Businesses = require 'models/businesses'
BusinessEdit = require 'views/business-edit'
RegisterUserView = require 'views/user-register-view'
ChangePasswordView = require 'views/change-password-view'

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

  registerUser: ->
    @view = new RegisterUserView  region:'main'
  changePassword: ->
    @view = new ChangePasswordView region:'main'