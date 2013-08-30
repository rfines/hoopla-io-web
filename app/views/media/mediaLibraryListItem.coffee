template = require 'templates/users/mediaLibraryListItem'
View = require 'views/base/view'
Media = require 'models/media'
ImageUtils = require 'utils/imageUtils'


module.exports = class mediaLibraryListItem extends View
  model : Media
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
    td.thumbUrl = $.cloudinary.url(ImageUtils.getId(td.url), {crop: 'fill', height: 163, width: 266})
    td.fullUrl = td.url
    td