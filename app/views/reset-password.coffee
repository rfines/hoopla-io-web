View = require 'views/base/view'
template = require 'templates/users/resetPassword'
User = require 'models/user'

# Site view is a top-level view which is bound to body.
module.exports = class ResetPasswordView extends View
  autoRender: true
  template: template
  container: "page-container"
  events:
    "submit form": 'resetPassword'

  initialize: ->
    super
    @model = new User()

  resetPassword: (e)->
    e.preventDefault()
    email = @$el.find('.email').val()
    password = @$el.find('.password').val()
    passConfirm = @$el.find('.password-confirm').val()
    if email and password and passConfirm
      if passConfirm is password
        @model.newPassword email, password, location.search.split('=')[1]
      else
        @$el.find('.errors').append("<span class='error'>The passwords do not match</span>")
    else
      @$el.find('.errors').append("<span class='error'>All fields are required.</span>")