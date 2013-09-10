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