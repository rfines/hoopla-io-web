template = require 'templates/media/listItem'
ImageUtils = require 'utils/imageUtils'
ListItemView = require 'views/base/listItem'

module.exports = class ListItem extends ListItemView
  className: 'media-library'
  template: template
  noun: 'media'
    
  getTemplateData: ->
    td = super
    td.thumbUrl = $.cloudinary.url(ImageUtils.getId(td.url), {crop: 'fill', height: 163, width: 266})
    td.fullUrl = td.url
    td
