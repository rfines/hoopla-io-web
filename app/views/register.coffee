template = require 'templates/register'
View = require 'views/base/view'
User = require 'models/user'

module.exports = class Register extends View
  template: template
  autoRender: false

  events:
    'click .btn' : 'register'

  initialize: ->
    super
    if window.user and window.authToken
      $.cookie('token', window.authToken, path: '/')
      $.cookie('user', window.user, path: '/')
      window.location = '/'
    else
      @render()


  register: (e) ->
    e.preventDefault()
    @model = new User();
    uname = @$el.find('input[name=email]').val()
    pword = @$el.find('input[name=password]').val()
    if uname and pword
        if $.cookie('token')
          $.removeCookie('token')
          $.removeCookie('user')
        @model.set
          email: uname
          password: pword
        @model.save  {}, {
          success: (model, response, options)-> 
            model.getToken uname, pword    
          error: (err, xhr, options) => 
            alert('Failed to create your account')
        }
    else
      alert('Email and Password are required')