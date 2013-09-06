template = require 'templates/common/imageChooser'
View = require 'views/base/view'

module.exports = class ImageChooser extends View
  autoRender: true
  className: 'image-chooser'
  template: template
  media= undefined
  file={}
  uploader = {}
  standAloneUpload = false

  initialize: (options)->
    super(options)
    @standAloneUpload = options.standAloneUpload

  events:
    'click .remove-button': 'removeFile'
  attach: ->
    super()

    @uploader = new plupload.Uploader(
      multipart : false
      runtimes: "html5,flash,silverlight,html4"
      browse_button: "choose-image"
      container: "uploadContainer"
      headers: {'X-AuthToken': $.cookie('token')}
      max_file_size: "10mb"
      url: "/api/media"
      flash_swf_url: "/plupload/js/plupload.flash.swf"
      silverlight_xap_url: "/plupload/js/plupload.silverlight.xap"
      filters: [
        title: "Image files"
        extensions: "jpg,jpeg,gif,png,pdf"
      ],
      drop_element: 'image-chooser-container'

    )
    
    
    @uploader.bind "Init", (up, params) =>
      if $('.uploadBtn').length >0
        $(".uploadBtn").click (e) =>
          @uploader.start()
          e.preventDefault()

    @uploader.bind "FilesAdded", (up, files) =>
      $('#choose-image').attr('disabled', true)
      $.each files, (i, file) =>
        @file = file
        $("#filelist").append "<div id=\"" + file.id + "\">" + file.name + " (" + plupload.formatSize(file.size) + ") <a class='remove-button'>Remove</a>" + "</div>"
      up.refresh() # Reposition Flash/Silverlight
    
    @uploader.bind "UploadProgress", (up, file) =>
      $("#" + file.id + " b").html file.percent + "%"

    @uploader.bind "Error", (up, err) =>
      $("#filelist").append "<div>Error: " + err.code + ", Message: " + err.message + ((if err.file then ", File: " + err.file.name else "")) + "</div>"
      up.refresh() # Reposition Flash/Silverlight

    @uploader.bind "FileUploaded", (up, file, response) =>
      response = JSON.parse(response.response)
      if response.success is true
        $("#" + file.id + " b").html "100%"
        file.status = plupload.DONE
        @media = response.media
        Chaplin.datastore.media.add(@media)
      else
        $("#" + file.id + " b").html "0%"
        file.status = plupload.FAILED
        @media = null

    @uploader.init()

  removeFile:(e)=>
    @uploader.removeFile(@file)
    $('#'+@file.id).remove()
    $('#choose-image').attr('disabled', false)

  uploadQueue: (cb)->
    @uploader.bind "UploadComplete", (up, files)=>
      cb @media
    @uploader.start()

  getTemplateData: ->
    td = super()
    td.standAloneUpload = @standAloneUpload
    td  