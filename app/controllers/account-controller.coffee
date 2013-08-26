Controller = require 'controllers/base/postLoginController'
PromotionTargetsList = require 'views/users-list-view'
PromotionTargets = require 'models/promotionTargets'
Businesses = require 'models/businesses'
BusinessEdit = require 'views/business/edit'
ChangePasswordView = require 'views/change-password-view'
User = require 'models/user'
ResetPasswordRequestView = require 'views/reset-password-request'
ResetPasswordView = require 'views/reset-password'

module.exports = class AccountController extends Controller
  changePassword: ->
    @view = new ChangePasswordView region:'main'

  resetPassword: ->
    @view = new ResetPasswordRequestView region: 'main'
    
  newPassword: ->
    @view = new ResetPasswordView region: 'main'

