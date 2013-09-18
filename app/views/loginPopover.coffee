template = require 'templates/loginPopover'
View = require 'views/base/view'
User = require 'models/user'

module.exports = class LoginPopover extends View
  autoRender: true
  template: template

  events:
    "click .loginButton": 'login'
    'click .cancel' : 'cancel'

  initialize: ->
    super
    @model = new User()

  attach: ->
    super

  login: (e)->
    console.log 'login'
    e.preventDefault()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    if uname and pword
      @model.getToken uname, pword
    else
      @$el.find('.alert').empty()
      @$el.find('.alert').addClass('alert-danger').html("<span class='error'>A username and password is required</span>")    

  cancel: (e) ->
    e.preventDefault()
    console.log 'cancel'