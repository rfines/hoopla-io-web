Controller = require 'controllers/base/postLoginController'
ChangePasswordView = require 'views/change-password-view'
ResetPasswordView = require 'views/reset-password'

module.exports = class AccountController extends Controller
  changePassword: ->
    @view = new ChangePasswordView region:'main'
   
  newPassword: ->
    @view = new ResetPasswordView region: 'main'

