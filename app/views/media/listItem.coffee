template = require 'templates/media/listItem'
ImageUtils = require 'utils/imageUtils'
ListItemView = require 'views/base/listItem'
Media = require 'models/media'

module.exports = class ListItem extends ListItemView
  className: 'media-library'
  template: template
  noun: 'media'
  model: Media
    
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
    td.thumbUrl = $.cloudinary.url(ImageUtils.getId(td.url), {crop: 'fill', height: 163, width: 266})
    td.fullUrl = td.url
    td