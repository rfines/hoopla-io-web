SiteView = require 'views/site-view'
Controller = require 'controllers/base/preLoginController'
MarketingView = require 'views/marketing/basic'
PreLoginHeaderView = require 'views/preLoginHeader'
TopNav = require 'views/topNavHome'
Footer = require 'views/footerHome'
ResetPasswordView = require 'views/reset-password'

module.exports = class HomeController extends Controller
  home: ->
    aboutTemplate = require('templates/home')
    @view = new MarketingView({region:'main', template : aboutTemplate});
  compositions: =>
    @compose 'site', SiteView
    @compose 'topNav', TopNav  
    @compose 'footer', Footer

  newPassword: ->
    @view = new ResetPasswordView region: 'main'