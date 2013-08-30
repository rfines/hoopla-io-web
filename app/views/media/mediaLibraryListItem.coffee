template = require 'templates/users/mediaLibraryListItem'
View = require 'views/base/view'
Media = require 'models/media'

module.exports = class mediaLibraryListItem extends View
  autoRender: true
  className: 'media-library'
  template: template

  initialize: ->
    super
    console.log @model

  events:
    "click .trash" : "destroy"

  destroy: (e) =>
    @model.destroy
      success: =>
        Chaplin.datastore.media.remove(@model)
        @dispose()
      error: =>
        console.log 'error'
    
  getTemplateData: ->
    td = super
    td.mediaUrl = td.url
    td