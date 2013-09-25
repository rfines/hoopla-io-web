template = require 'templates/loginPopover'
View = require 'views/base/view'
User = require 'models/user'

module.exports = class LoginPopover extends View
  template: template

  events:
    "click .loginButton": 'login'
    'click .cancel' : 'cancel'
    'click .forgotPasswordButton' : 'forgotPassword'

  initialize: ->
    super
    @model = new User()

  attach: ->
    super
    @$el.find('.password').focus()

  login: (e)->
    e.preventDefault()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    if uname and pword
      @publishEvent 'startWaiting'
      @model.getToken uname, pword, {
        onSuccess: =>
          $('#loginModal').modal('hide')
          if Chaplin.datastore.business.hasNone()
            Chaplin.helpers.redirectTo {url: 'myBusinesses'}
          else      
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
    Chaplin.helpers.redirectTo {url: '/forgotPassword'}

  cancel: (e) ->
    e.preventDefault()

