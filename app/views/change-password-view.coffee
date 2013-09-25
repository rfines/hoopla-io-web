View = require 'views/base/view'
template = require 'templates/users/password'
User = require 'models/user'

# Site view is a top-level view which is bound to body.
module.exports = class ChangePasswordView extends View
  template: template
  container: "page-container"
  events:
    "submit form": 'changePassword'

  initialize: ->
    super
    @model = new User()

  changePassword: (e)->
    e.preventDefault()
    oldPass = @$el.find('.currentPassword').val()
    pword = @$el.find('.password').val()
    pwordConfirm = @$el.find('.password-confirm').val()
    if oldPass and pword and pwordConfirm
      if pwordConfirm is pword
        @model.changePassword $.cookie('user'), pword, oldPass
    else
      @$el.find('.errors').append("<span class='error'>Current password and new password are required.</span>")