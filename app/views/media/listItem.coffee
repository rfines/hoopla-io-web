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
    "click .trash" : "destroy"
    "click .deleteItem":"closeModal"
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
    td
  openModal:(e)=>
    e.preventDefault() if e
    $("#modal_#{@model.id}").modal({
      keyboard:true
    }).show()
  closeModal:(e)=>
    e.preventDefault() if e
    console.log "closing"
    $("#modal_#{@model.id}").modal('hide')
