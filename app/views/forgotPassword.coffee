View = require 'views/base/view'
template = require 'templates/users/forgotPassword'
User = require 'models/user'

# Site view is a top-level view which is bound to body.
module.exports = class ResetPasswordRequestView extends View
  template: template
  container: "page-container"
  events:
    "submit form": 'resetPassword'

  initialize: ->
    super
    @model = new User()

  resetPassword: (e) =>
    e.preventDefault()
    email = @$el.find('.email').val()
    if email
      @model.resetPassword email
      @$el.find('.alert-success').removeClass('hide')
    else
      @$el.find('.alert-danger').removeClass('hide')
      @$el.find('.alert-danger').append("<span class='error'>A valid email address is required.</span>")