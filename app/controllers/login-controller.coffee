SiteView = require 'views/site-view'
TopNav = require 'views/topNavHome'
Footer = require 'views/footerHome'
Controller = require 'controllers/base/preLoginController'

module.exports = class HomeController extends Controller

  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav  
    @compose 'footer', Footer

  logout: ->
    $.removeCookie('token')
    $.removeCookie('user')
    delete Chaplin.datastore.user
    window.location = "/"