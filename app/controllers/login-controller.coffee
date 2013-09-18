SiteView = require 'views/site-view'
TopNav = require 'views/topNavHome'
Footer = require 'views/footerHome'
Controller = require 'controllers/base/preLoginController'
LoginView = require 'views/login-view'
ForgotPassword = require 'views/forgotPassword'

module.exports = class HomeController extends Controller
  login: ->
    @view = new LoginView region:'main'

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav  
    @compose 'footer', Footer

  logout: ->
    $.removeCookie('token')
    $.removeCookie('user')
    delete Chaplin.datastore.user
    @publishEvent "!router:route", "/"