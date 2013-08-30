Controller = require 'controllers/base/postLoginController'
Event = require 'models/event'

module.exports = class DemoController extends Controller
  create: ->
    EventEdit = require 'views/event/edit'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        newEvent = new Event()
        if Chaplin.datastore.business.hasOne()
          newEvent.set 
            'business' : Chaplin.datastore.business.first().id
            'host' : Chaplin.datastore.business.first().id
            'location' : Chaplin.datastore.business.first().get('location')
        Chaplin.datastore.load 
          name : 'event'
          success: =>
            @view = new EventEdit
              region: 'main'
              collection : Chaplin.datastore.event
              model : newEvent
          error: (model, response) =>
            console.log 'error'
            console.log response        

  edit: (params) ->  
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
              model : Chaplin.datastore.event.get(params.id)
          error: (model, response) =>
            console.log 'error'
            console.log response 

  list: ->
    EventList = require 'views/event/list'
    Chaplin.datastore.load 
      name : 'business'
      success: =>
        Chaplin.datastore.load 
          name : 'event'
          success: =>
            @view = new EventList
              region: 'main'
              collection : Chaplin.datastore.event
          error: (model, response) =>
            console.log 'error'
            console.log response