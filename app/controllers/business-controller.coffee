Controller = require 'controllers/base/postLoginController'
Businesses = require 'models/businesses'

module.exports = class BusinessController extends Controller

  edit: (params) ->
    BusinessEdit = require 'views/business/edit'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new BusinessEdit
          region: 'main'
          collection : Chaplin.datastore.business
          model : Chaplin.datastore.business.get(params.id)

  list: (params) ->
    BusinessList = require 'views/business/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new BusinessList
          region: 'main'
          collection : Chaplin.datastore.business
          params : params
   
