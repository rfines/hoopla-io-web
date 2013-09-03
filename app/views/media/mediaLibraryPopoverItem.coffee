template = require 'templates/common/imageLibraryItem'
View = require 'views/base/view'
Media = require 'models/media'
ImageUtils = require 'utils/imageUtils'


module.exports = class mediaLibraryListItem extends View
  autoRender: true
  className: 'media-library'
  template: template

  initialize: ->
    super

  getTemplateData: ->
    td = super
    td.thumbUrl = $.cloudinary.url(ImageUtils.getId(td.url), {crop: 'fill', height: 163, width: 266})
    td
  
  events:
    "click":"assignImage"

  assignImage:(e)->
    @publishEvent('selectedMedia', @model)