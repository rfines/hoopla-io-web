template = require 'templates/business/edit'
View = require 'views/base/view'
Business = require 'models/business'
AddressView = require 'views/address'

module.exports = class BusinessEditView extends View
  autoRender: true
  className: 'users-list'
  template: template

  initialize: ->
    super
    @model = @model || new Business()

  attach: ->
    super 
    uploader = new plupload.Uploader({
      runtimes: 'html5,flash,silverlight,html4',
      browse_button: $('browse'),
      max_file_size: '15mb',
      contatiner:$('.upload'),
      filters : [
        {title : "Image files", extensions : "jpg,gif,png"}
      ],
      url: "/api/media/upload/"
      retry:
        enableAuto:true
      init: ->
        PostInit: ()->
          $('fileList').innerHTML = ''

          $('uploadFiles').onclick = ()-> 
            uploader.start()
            return false
          
      ,
      FilesAdded: (up, files) ->
        plupload.each(files, (file) ->
          $('fileList').innerHTML += '<div id="' + file.id + '">' + file.name + ' (' + plupload.formatSize(file.size) + ') <b></b></div>'
        )
      ,
      UploadProgress: (up, file) ->
        $(file.id).getElementsByTagName('b')[0].innerHTML = '<span>' + file.percent + "%</span>"
      ,

      Error: (up, err) ->
        $('console').innerHTML += "\nError #" + err.code + ": " + err.message
      
    })
    uploader.init()
    @modelBinder.bind @model, @$el
    @subview("geoLocation", new AddressView({model: @model, container : @$el.find('.geoLocation')}))

  events:
    'submit form' : 'save'

  save: (e) ->
    e.preventDefault()
    @model.set
      location : @subview('geoLocation').getLocation()
    @model.save {}, {
      success: =>
        @publishEvent '!router:route', 'myBusinesses'
    }