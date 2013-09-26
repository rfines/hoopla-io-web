View = require 'views/base/view'
template = require 'templates/login'
User = require 'models/user'

# Site view is a top-level view which is bound to body.
module.exports = class LoginView extends View
  template: template
  container: "page-container"
  events:
    "submit form": 'login'

  initialize: ->
    super
    @model = new User()

  login: (e)->
    e.preventDefault()
    uname = @$el.find('.username').val()
    pword = @$el.find('.password').val()
    if uname and pword
      @model.getToken uname, pword
    else
      @$el.find('.errors').empty().html("<span class='error'>A username and password is required</span>")
  

