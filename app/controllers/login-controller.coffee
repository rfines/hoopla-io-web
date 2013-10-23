Login = require 'views/login'
SiteView = require 'views/site-view'
Register = require 'views/register'

module.exports = class LoginController extends Chaplin.Controller

  register: (params) ->
    @compose 'site', SiteView
    @view = new Register
      region: 'main'

  login: (params) ->
    @compose 'site', SiteView
    @view = new Login
      region:'main'
      showForgotPassword : params?.showForgotPassword
      showResetPassword: params?.showResetPassword      

  logout: ->
    $.removeCookie('token')
    $.removeCookie('user')
    delete Chaplin.datastore.user
    window.location = "#{window.wpUrl}"