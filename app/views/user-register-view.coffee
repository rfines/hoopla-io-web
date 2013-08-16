View = require 'views/base/view'
template = require 'templates/users/register'
User = require 'models/user'
module.exports = class UserRegisterView extends View
  autoRender: true
  template: template
  initialize: ->
    super
    @model = new User()

  attach: ->
    super

  events: 
    "submit form": "register"

  register: (e)->
    e.preventDefault()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    pwordconfirm =@$el.find('.password-confirm').val()
    name = @$el.find('.name').val()
    if uname and pword and pwordconfirm and name
      if pword != pwordconfirm
        @$el.find('.errors').append("<span class='error'>Passwords do not match</span>")
      else
        if $.cookie('token')
          $.removeCookie('token')
          $.removeCookie('user')
        @model.set
          name: name
          email: uname
          password: pword
        @model.save  {}, {
          success: (model, response, options)-> model.getToken uname, pword
          
          error: (model, xhr, options)-> @$el.find('.errors').append("<span class='error'>#{model}</span>")
        }
    else
      @$el.find('.errors').append("<span class='error'>All fields are required</span>")
  


