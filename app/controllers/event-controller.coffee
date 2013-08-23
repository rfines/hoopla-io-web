Controller = require 'controllers/base/AuthenticatedController'

module.exports = class DemoController extends Controller
  create: ->
    EventEdit = require 'views/event/edit'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        Chaplin.datastore.load 
          name : 'event'
          success: =>
            @view = new EventEdit
              region: 'main'
              collection : Chaplin.datastore.event
          error: (model, response) =>
            console.log 'error'
            console.log response        

  edit: (params) ->  
    console.log 'edit'
    EventEdit = require 'views/event/edit'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        Chaplin.datastore.load 
          name : 'event'
          success: =>
            console.log 'event success'
            @view = new EventEdit
              region: 'main'
              collection : Chaplin.datastore.event
              model : Chaplin.datastore.event.get(params.id)
          error: (model, response) =>
            console.log 'error'
            console.log response 

  list: ->
    EventList = require 'views/event/list'
    Chaplin.datastore.load 
      name : 'event'
      success: =>
        @view = new EventList
          region: 'main'
          collection : Chaplin.datastore.event
      error: (model, response) =>
        console.log 'error'
        console.log response