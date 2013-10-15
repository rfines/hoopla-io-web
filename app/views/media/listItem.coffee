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

  events:
    "click .thumbnail": "openModal"
    "click .enlarge":"openModal"
    "click .deleteItem.trash" : "destroy"
    "click .closeModal":"closeModal"
    "click .modal-backdrop":"closeModal"

  destroy: (e) =>
    e.preventDefault() if e
    if not Chaplin.datastore.business.hasMedia(@model.id) and not Chaplin.datastore.event.hasMedia(@model.id)
      @model.destroy
        success: =>
          Chaplin.datastore.media.remove(@model)
          @dispose()
    else
      alert('This image is currently in use by your businesses and events.')
    
  getTemplateData: ->
    td = super
    td.thumbUrl = $.cloudinary.url(ImageUtils.getId(td.url), {crop: 'fill', height: 163, width: 266})
    td.fullUrl = td.url
    td.hasMedia = Chaplin.datastore.media?.models.length > 0
    td
  openModal:(e)=>
    e.preventDefault() if e
    selector= "#modal_#{@model.id}"
    $("#{selector}").modal({
      keyboard:true,
      backdrop:true,
      show:true
    })
  closeModal:(e)=>
    e.preventDefault() if e
    selector= "#modal_#{@model.id}"
    $("#{selector}").modal("hide")
    