SiteView = require 'views/site-view'
Controller = require 'controllers/base/preLoginController'
UsersList = require 'views/users-list-view'
Users = require 'models/users'
RegisterUserView = require 'views/user-register-view'

module.exports = class RegistrationController extends Controller

  registerUser: ->
    @view = new RegisterUserView  region:'main'    

  compositions: =>
    @compose 'site', SiteView
