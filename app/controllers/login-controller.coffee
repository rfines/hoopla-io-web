SiteView = require 'views/site-view'
Controller = require 'controllers/base/preLoginController'
LoginView = require 'views/login-view'

module.exports = class HomeController extends Controller
  login: ->
    @view = new LoginView region:'main'

  compositions: =>
    @compose 'site', SiteView    
  