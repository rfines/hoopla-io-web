View = require 'views/base/view'
template = require 'templates/users/forgotPassword'
User = require 'models/user'

# Site view is a top-level view which is bound to body.
module.exports = class ResetPasswordRequestView extends View
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
    if email
      @model.resetPassword email
    else
      @$el.find('.errors').append("<span class='error'>A valid email address is required.</span>")