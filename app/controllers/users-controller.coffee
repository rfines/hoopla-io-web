Controller = require 'controllers/base/postLoginController'
UsersList = require 'views/users-list-view'
Users = require 'models/users'

module.exports = class UsersController extends Controller
  index: ->
    @collection = new Users()
    @collection.fetch
      success: =>
        @view = new UsersList(
          region: 'main'
          collection : @collection
        )
    
