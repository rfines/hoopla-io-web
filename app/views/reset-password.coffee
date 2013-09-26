View = require 'views/base/view'
template = require 'templates/users/resetPassword'
User = require 'models/user'

# Site view is a top-level view which is bound to body.
module.exports = class ResetPasswordView extends View
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
        @model.newPassword email, password, location.search.split('=')[1], {
          onSuccess: =>
            @publishEvent 'stopWaiting'
            $('#resetPasswordModal').modal('hide')
            $.removeCookie('token')
            $.removeCookie('user')
            @$el.find('.alert').empty().hide()  
            window.location = "/login"
          onError: (body, response, xHr) =>
            @publishEvent 'stopWaiting'
            if body.status is 401
              @$el.find('.alert').empty().html("<span class='error'>Your email address was not found. Please register or try to log in using a different account.</span>").show()
            else
              @$el.find('.alert').empty().html("<span class='error'>Something went wrong.</span>").show()           
        }
      else
        @$el.find('.alert').show().html("<span class='error'>The passwords do not match</span>").show()
    else
      @$el.find('.alert').show().html("<span class='error'>All fields are required.</span>").show()
