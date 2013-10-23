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
      @model = new User()
      @render()


  register: (e) ->
    e.preventDefault()
    @clearErrors()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    pwordconfirm =@$el.find('.password-confirm').val()
    if uname and pword and pwordconfirm
      if pword != pwordconfirm
        @showError "Passwords do not match.", ['password', 'password-confirm']
      else
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
            @showError xhr.responseJSON
        }
    else
      @showError "All fields are required", ['email', 'password', 'password-confirm']

  showError: (msg, fields) =>   
    @$el.find('.alert').show()
    if _.isObject(msg) and msg.message.indexOf('duplicate') > -1
      @$el.find('.message').text("#{@$el.find('.username').val()} is already used on hoopla.io.");
    else
      @$el.find('.message').text(msg)    
    if fields
      for x in fields
        @$el.find("input[name='#{x}']").parent().addClass('has-error')
  
  clearErrors: () ->
    @$el.find('.has-error').removeClass('has-error')