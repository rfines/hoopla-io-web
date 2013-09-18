template = require 'templates/home'
View = require 'views/base/view'
Users = require 'models/users'


module.exports = class HomePageView extends View
  autoRender: true
  className: 'home-page'
  template: template

  events:
    "submit form.try-hoopla-now":"tryHoopla"

  tryHoopla:(e)->
    email = @$el.find('.email').val()
    password = @$el.find('.password').val()
    if email and password
      console.log email, password
    else
      console.log "Email address and password is required"