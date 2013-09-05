SiteView = require 'views/site-view'
TopNav = require 'views/topNavHome'
Footer = require 'views/footerHome'
Controller = require 'controllers/base/preLoginController'
LoginView = require 'views/login-view'
ResetPasswordRequestView = require 'views/reset-password-request'

module.exports = class HomeController extends Controller
  login: ->
    @view = new LoginView region:'main'

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav  
    @compose 'footer', Footer
  
  resetPassword: ->
    @view = new ResetPasswordRequestView region: 'main'  

  logout: ->
    $.removeCookie('token')
    $.removeCookie('user')
    delete Chaplin.datastore.user
    window.location = '/'    