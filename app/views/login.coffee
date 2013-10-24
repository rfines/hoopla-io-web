template = require 'templates/login'
View = require 'views/base/view'
User = require 'models/user'

module.exports = class Login extends View
  template: template

  events:
    "click .loginButton": 'login'
    'click .cancel' : 'cancel'
    'click .forgotPasswordButton' : 'forgotPassword'
    'keyup .password': 'submitOnEnter'
    'keyup #loginModal': 'submitOnEnter'

  initialize: (@options)->
    super(@options)
    @model = new User()

  attach: ->
    super
    @$el.find('.password').focus()
    @publishEvent 'showForgotPassword' if @options.showForgotPassword
    @publishEvent 'showResetPassword' if @options.showResetPassword     

   submitOnEnter:(e)=>
    code = (if e.keyCode then e.keyCode else e.which)
    if code is 13
      @login(e)
    else if code is 27
      @cancel(e)

  login: (e)->
    e.preventDefault()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    if uname and pword
      @publishEvent 'startWaiting'
      @model.getToken uname, pword, {
        onSuccess: =>
          console.log 'success'
          $('#loginModal').modal('hide')
          if Chaplin.datastore.business.hasNone()
            Chaplin.helpers.redirectTo {url: 'myBusinesses'}
          else      
            console.log 'redirect to events'
            Chaplin.helpers.redirectTo {url: 'myEvents'}
        onError: (msg) =>
          @publishEvent 'stopWaiting'
          @$el.find('.alert').empty()
          @$el.find('.alert').addClass('alert-danger').html("<span class='error'>#{msg}</span>")              
      }
    else
      @$el.find('.alert').empty()
      @$el.find('.alert').addClass('alert-danger').html("<span class='error'>A username and password is required</span>")

  forgotPassword: (e) ->
    e.preventDefault() if e
    Chaplin.helpers.redirectTo {url: 'forgotPassword'}

  cancel: (e) ->
    e.preventDefault()
    @$el.find('.username').val('')
    @$el.find('.password').val('')
    $('#loginModal').modal('hide')
