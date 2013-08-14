View = require 'views/base/view'
template = require 'views/templates/login'

# Site view is a top-level view which is bound to body.
module.exports = class LoginView extends View
  autoRender: true
  template: template
  container: "page-container"
  events:
    "submit form": 'login'

  login: (e)->
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    if uname and pword
      data = {}
      data.password = pword
      data.email = uname
      $.ajax
        type: 'POST',
        url:  '/api/tokenRequest',
        data: data,
        success: (body,response, xHr)->
          console.log body
          $.cookie('token', body.authToken, path: '/')

      
    else
      @$el.find('.errors').append("<span class='error'>A username and password is required</span>")

    e.preventDefault()
