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
    @$el.find('.alert').hide()
    super

  events: 
    "submit form": "register"

  register: (e) ->
    e.preventDefault()
    @clearErrors()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    pwordconfirm =@$el.find('.password-confirm').val()
    name = @$el.find('.name').val()
    if uname and pword and pwordconfirm and name
      if pword != pwordconfirm
        @showError "Passwords do not match.", ['password', 'password-confirm']
      else
        if $.cookie('token')
          $.removeCookie('token')
          $.removeCookie('user')
        @model.set
          name: name
          email: uname
          password: pword
        @model.save  {}, {
          success: (model, response, options)-> 
            model.getToken uname, pword     
          error: (model, xhr, options) => 
            console.log 'error'
            @showError "#{model}"
        }
    else
      @showError "All fields are required", ['name', 'email', 'password', 'password-confirm']

  showError: (msg, fields) =>    
    @$el.find('.alert').show()
    @$el.find('.message').text(msg)    
    if fields
      for x in fields
        @$el.find("input[name='#{x}']").parent().addClass('has-error')
  
  clearErrors: () ->
    @$el.find('.has-error').removeClass('has-error')