template = require 'templates/common/imageChooser'
View = require 'views/base/view'

module.exports = class ImageChooser extends View
  autoRender: true
  className: 'users-list'
  template: template
  media  = undefined
  initialize: ->
    super

  attach: ->
    super()
    uploader = new plupload.Uploader(
      multipart : false
      runtimes: "html5,flash,silverlight,html4"
      browse_button: "imageChooser"
      container: "uploadContainer"
      max_file_size: "10mb"
      url: "/api/media/upload"
      flash_swf_url: "/plupload/js/plupload.flash.swf"
      silverlight_xap_url: "/plupload/js/plupload.silverlight.xap"
      filters: [
        title: "Image files"
        extensions: "jpg,jpeg,gif,png"
      ]
    )
    uploader.bind "Init", (up, params) ->
      $("#filelist").html "<div>Current runtime: " + params.runtime + "</div>"
    $("#uploadfiles").click (e) ->
      uploader.start()
      e.preventDefault()
    uploader.init()
    uploader.bind "FilesAdded", (up, files) ->
      $.each files, (i, file) ->
        $("#filelist").append "<div id=\"" + file.id + "\">" + file.name + " (" + plupload.formatSize(file.size) + ") <b></b>" + "</div>"

      up.refresh() # Reposition Flash/Silverlight
    
    uploader.bind "UploadProgress", (up, file) ->
      $("#" + file.id + " b").html file.percent + "%"

    uploader.bind "Error", (up, err) ->
      $("#filelist").append "<div>Error: " + err.code + ", Message: " + err.message + ((if err.file then ", File: " + err.file.name else "")) + "</div>"
      up.refresh() # Reposition Flash/Silverlight

    uploader.bind "FileUploaded", (up, file) ->
      media = file
      $("#" + file.id + " b").html "100%"

  getMedia : ->
    @media