SiteView = require 'views/site-view'
Controller = require 'controllers/base/preLoginController'
HomePageView = require 'views/home'

module.exports = class HomeController extends Controller
  home: ->
    template = require('templates/home')
    @view = new HomePageView({region:'main'});

  compositions: =>
    @compose 'site', SiteView

  newPassword: ->
    @view = new ResetPasswordView region: 'main'