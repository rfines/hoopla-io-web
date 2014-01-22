template = require 'templates/common/imageChooser'
View = require 'views/base/view'

module.exports = class ImageChooser extends View
  className: 'image-chooser'
  template: template
  media= undefined
  file={}
  uploader = {}
  standAloneUpload = false
  dropped = false

  initialize: (options)->
    super(options)
    @standAloneUpload = options.data.standAloneUpload
    @showControls = options.data.showControls if options.data.showControls

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
      ]
    )
    @$el.find('.helpTip').tooltip()
        
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
      up.refresh()
      if @standAloneUpload is false and $('.imagePreview').length > 0
        @handleFiles()
    
    @uploader.bind "UploadProgress", (up, file) =>
      if file.percent < 100
        $("#" + file.id ).html file.name + ' uploading...' 
      

    @uploader.bind "Error", (up, err) =>
      $("#filelist").append "<div>Error: " + err.code + ", Message: " + err.message + ((if err.file then ", File: " + err.file.name else "")) + "</div>"
      up.refresh()

    @uploader.bind "FileUploaded", (up, file, response) =>
      resp = JSON.parse(response.response)
      @publishEvent "stopWaiting"
      if resp.success is true
        if @standAloneUpload is true
          $('#choose-image').attr('disabled', false)
          $("#filelist div").empty()
        file.status = plupload.DONE
        @media = resp.media
        Chaplin.datastore.media.add(@media)
      else
        if @standAloneUpload is true
          $('#choose-image').attr('disabled', false)
          $("#" + @file.id).remove()
        $("#" + @file.id).html "0%"
        file.status = plupload.FAILED
        @media = undefined

    @uploader.init()

  removeFile:(e)=>
    @uploader.removeFile(@file)
    $("#filelist div").remove()
    $('#choose-image').attr('disabled', false)

  uploadQueue: (cb)->
    @uploader.bind "UploadComplete", (up, files)=>
      cb @media
    @publishEvent "startWaiting"
    @uploader.start()

  getTemplateData: ->
    td = super()
    td.standAloneUpload = @standAloneUpload
    td.showControls = @showControls
    td

  handleFiles : () ->
    imageDataUrl = ""
    input = []
    if $("input[type=file]")[0].files and $("input[type=file]")[0].files.length > 0
      input = $("input[type=file]")[0].files
      file = input[0]
      imageType = /image.*/
      reader = new FileReader() 
      if file?.type.match(imageType)
         reader.onload = (() ->
            (e) ->
              imageDataUrl = e.target.result
              imgs = $(".imagePreview")
              _.each imgs, (img, index, list)=>
                img.file = file
                img.src = imageDataUrl     
          )()
        reader.readAsDataURL file
          