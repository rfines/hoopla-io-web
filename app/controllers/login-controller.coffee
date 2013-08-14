Controller = require 'controllers/base/controller'
LoginView = require 'views/login-view'

module.exports = class HomeController extends Controller
  login: ->
    @view = new LoginView region:'main'
  