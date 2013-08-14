Controller = require 'controllers/base/controller'
HomePageView = require 'views/home-page-view'
LoginView = require 'views/login-view'

module.exports = class HomeController extends Controller
  index: ->
    @view = new HomePageView region: 'main'
  login: ->
    @view = new LoginView region:'main'
  