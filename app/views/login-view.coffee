View = require 'views/base/view'
template = require 'views/templates/login'
User = require 'models/user'

# Site view is a top-level view which is bound to body.
module.exports = class LoginView extends View
  autoRender: true
  template: template
  container: "page-container"
  events:
    "submit form": 'login'

  login: (e)->
    e.preventDefault()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    if uname and pword
      $.ajax
        type: 'POST',
        contentType: 'application/json',
        url:  '/api/tokenRequest',
        data: JSON.stringify({password : pword,email : uname}),
        success: (body,response, xHr) =>
          $.cookie('token', body.authToken, path: '/')
          $.cookie('user', body.user, path: '/')
          user = new User()
          user.id = body.user
          console.log 'ready to fetch'
          console.log user.url()
          user.fetch
            success: ->
              console.log 'success!!'
              @loginSuccess(user)
        error: 
          console.log 'could not authenticate'
    else
      @$el.find('.errors').append("<span class='error'>A username and password is required</span>")

  loginSuccess: (user) =>
    mediator.user = user
    if mediator.redirectUrl == null
      @publishEvent '!router:route', 'dashboard'
    else
      @publishEvent '!router:route', mediator.redirectUrl
    @publishEvent 'loginStatus', true      

    e.preventDefault()
