Controller = require 'controllers/base/AuthenticatedController'
UsersList = require 'views/users-list-view'
Businesses = require 'models/businesses'

module.exports = class BusinessController extends Controller
  list: ->
    @collection = new Businesses()
    @collection.fetch
      success: =>
        ###
        @view = new BusinessList(
          region: 'main'
          collection : @collection
        )
        ###
      error: (model, response) =>
        console.log 'error'
        console.log response