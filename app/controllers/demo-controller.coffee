Controller = require 'controllers/base/postLoginController'
PromotionTargetsList = require 'views/users-list-view'
PromotionTargets = require 'models/promotionTargets'
Businesses = require 'models/businesses'
BusinessEdit = require 'views/business/edit'
ChangePasswordView = require 'views/change-password-view'
User = require 'models/user'
ResetPasswordRequestView = require 'views/reset-password-request'
ResetPasswordView = require 'views/reset-password'

module.exports = class DemoController extends Controller
  changePassword: ->
    @view = new ChangePasswordView region:'main'

  eventDashboard: ->
    EventList = require 'views/event/list'
    Chaplin.datastore.load 
      name : 'event'
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event
      error: (model, response) =>
        console.log 'error'
        console.log response

  resetPassword: ->
    @view = new ResetPasswordRequestView region: 'main'
  newPassword: ->
    @view = new ResetPasswordView region: 'main'

