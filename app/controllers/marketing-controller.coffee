Controller = require 'controllers/base/preLoginController'
MarketingView = require 'views/marketing/basic'

module.exports = class HomeController extends Controller
  about: ->
    aboutTemplate = require('templates/marketing/about')
    @view = new MarketingView({region:'main', template : aboutTemplate});

  localBusinesses: ->
    aboutTemplate = require('templates/marketing/localBusinesses')
    @view = new MarketingView({region:'main', template : aboutTemplate});

  publishers: ->
    aboutTemplate = require('templates/marketing/publishers')
    @view = new MarketingView({region:'main', template : aboutTemplate});        
  