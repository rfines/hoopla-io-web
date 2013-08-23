Controller = require 'controllers/base/postLoginController'
UsersList = require 'views/users-list-view'
Businesses = require 'models/businesses'

module.exports = class BusinessController extends Controller

  create: ->
    BusinessEdit = require 'views/business/edit'
    console.log 'create business'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        @view = new BusinessEdit
          region: 'main'
          collection : Chaplin.datastore.business
      error: (model, response) =>
        console.log 'error'
        console.log response


  edit: (params) ->
    console.log 'edit business'
    BusinessEdit = require 'views/business/edit'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        @view = new BusinessEdit
          region: 'main'
          collection : Chaplin.datastore.business
          model : Chaplin.datastore.business.get(params.id)
      error: (model, response) =>
        console.log 'error'
        console.log response   

  list: ->
    BusinessList = require 'views/business/list'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        @view = new BusinessList
          region: 'main'
          collection : Chaplin.datastore.business
      error: (model, response) =>
        console.log 'error'
        console.log response        