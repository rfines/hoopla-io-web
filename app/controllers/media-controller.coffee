Controller = require 'controllers/base/postLoginController'
Medias = require 'models/medias'
List = require 'views/media/list'

module.exports = class MediaController extends Controller
  index: ->
    Chaplin.datastore.loadEssential 
      success: =>
        @view = new List
          region: 'main'
          collection : Chaplin.datastore.media
          standAloneUpload: true
      error: (model, response) =>
        console.log response   