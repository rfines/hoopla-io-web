View = require 'views/base/view'
template = require 'templates/account/manage'

module.exports = class Edit extends View
  className : 'account-manage'
  template: template

  events:
    'click .saveButton' : 'save'

  initialize: ->
    super
    @model = Chaplin.datastore.user

  attach: ->
    super
    @$el.find('.message').hide()
    @modelBinder.bind @model, @$el  
    Backbone.Validation.bind(@)

  save: (e) =>
    @clearErrors()
    @saveUser()
    @changePassword()

  saveUser: =>
    if not @model.validate()
      @model.save {}, {
        success: =>
          @$el.find('.message').show().addClass('alert-success').append("<div class='row'>Your account has been updated</div>")
      }
    else
      for x in _.keys(@model.validate())
        @$el.find("input[name='#{x}']").parent().addClass('has-error')

  clearErrors: =>
    @$el.find('.message').empty().hide()
    @$el.find(".has-error").removeClass('has-error')

  changePassword: (oldPass, newPass, newPassConfirm)->
    oldPass = @$el.find("input[name='currentPassword']").val()
    pword = @$el.find("input[name='newPassword']").val()
    pwordConfirm = @$el.find("input[name='newPassword-confirm']").val()
    if oldPass and pword and pwordConfirm
      if pwordConfirm is pword
        @model.changePassword $.cookie('user'), pword, oldPass, {
          onSuccess: =>
            @$el.find('.message').show().addClass('alert-success').append("<div class='row'>Your password has been changed.</div>")
          onError: =>
            console.log "Some error"
            @$el.find('.message').show().addClass('alert-danger').append("<div class='row'>Unable to change your password.</div>")
          }