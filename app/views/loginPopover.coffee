template = require 'templates/loginPopover'
View = require 'views/base/view'
User = require 'models/user'

module.exports = class LoginPopover extends View
  autoRender: true
  template: template

  events:
    "submit form": 'login'

  initialize: ->
    super
    @model = new User()

  attach: ->
    super

  login: (e)->
    e.preventDefault()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    if uname and pword
      @model.getToken uname, pword
    else
      @$el.find('.errors').append("<span class='error'>A username and password is required</span>")    