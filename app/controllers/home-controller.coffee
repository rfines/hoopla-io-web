SiteView = require 'views/site-view'
Controller = require 'controllers/base/preLoginController'
HomePageView = require 'views/home'

module.exports = class HomeController extends Controller
  home: (params) ->
    template = require('templates/home')
    @view = new HomePageView
      region:'main'
      showLogin : params?.showLogin
      showForgotPassword : params?.showForgotPassword
      showResetPassword: params?.showResetPassword
      signup : params?.signup

  compositions: =>
    @compose 'site', SiteView