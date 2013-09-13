Controller = require 'controllers/base/postLoginController'
ChangePasswordView = require 'views/change-password-view'
ResetPasswordView = require 'views/reset-password'
ManageAccount = require 'views/account/manage'

module.exports = class AccountController extends Controller
  changePassword: ->
    @view = new ChangePasswordView region:'main'

  manage: ->
    @view = new ManageAccount region: 'main'

