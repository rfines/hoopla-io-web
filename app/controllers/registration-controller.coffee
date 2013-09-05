SiteView = require 'views/site-view'
TopNav = require 'views/topNavHome'
Footer = require 'views/footerHome'
Controller = require 'controllers/base/preLoginController'
RegisterUserView = require 'views/user-register-view'

module.exports = class RegistrationController extends Controller

  registerUser: ->
    @view = new RegisterUserView  region:'main'    

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav  
    @compose 'footer', Footer
