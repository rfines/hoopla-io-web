Controller = require 'controllers/base/controller'
UsersList = require 'views/users-list-view'
Businesses = require 'models/businesses'

module.exports = class BusinessController extends Controller
  list: ->
    @collection = new Businesses()
    @collection.fetch
      success: =>
        console.log @collection.models[0].get('name')
        ###
        @view = new BusinessList(
          region: 'main'
          collection : @collection
        )
        ###
    
