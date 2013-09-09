Controller = require 'controllers/base/postLoginController'
Widget = require 'models/widget'

module.exports = class AppController extends Controller

  list: ->
    WidgetList = require 'views/widget/list'
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new WidgetList
          region: 'main'
          collection : Chaplin.datastore.widget

  create: ->
    WidgetEdit = require 'views/widget/edit'
    Chaplin.datastore.loadEssential 
      success: =>    
        w = new Widget()
        @view = new WidgetEdit
          region: 'main'
          collection : Chaplin.datastore.widget
          model : w

  edit: (params) ->
    WidgetEdit = require 'views/widget/edit'
    Chaplin.datastore.loadEssential 
      success: =>
        console.log Chaplin.datastore.widget
        @view = new WidgetEdit
          region: 'main'
          collection : Chaplin.datastore.widget
          model : Chaplin.datastore.widget.get(params.id)
