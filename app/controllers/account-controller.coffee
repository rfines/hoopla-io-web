Controller = require 'controllers/base/postLoginController'

ChangePasswordView = require 'views/change-password-view'

ResetPasswordRequestView = require 'views/reset-password-request'
ResetPasswordView = require 'views/reset-password'

module.exports = class AccountController extends Controller
  changePassword: ->
    @view = new ChangePasswordView region:'main'

  resetPassword: ->
    @view = new ResetPasswordRequestView region: 'main'
    
  newPassword: ->
    @view = new ResetPasswordView region: 'main'

