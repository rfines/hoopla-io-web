Controller = require 'controllers/base/AuthenticatedController'
UsersList = require 'views/users-list-view'
Businesses = require 'models/businesses'

module.exports = class BusinessController extends Controller
  list: ->
    console.log 'list businesses'
    @collection = new Businesses()
    @collection.fetch
      success: =>
        console.log 'hi'
        console.log @collection.models
        ###
        @view = new BusinessList(
          region: 'main'
          collection : @collection
        )
        ###
      error: (model, response) =>
        console.log 'error'
        console.log response
    
