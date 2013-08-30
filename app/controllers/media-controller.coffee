Controller = require 'controllers/base/postLoginController'
Medias = require 'models/medias'
MediaLibraryView = require 'views/media/mediaLibraryList'

module.exports = class MediaController extends Controller
  index: ->
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new MediaLibraryView
          region: 'main'
          collection : Chaplin.datastore.media
      error: (model, response) =>
        console.log response
    