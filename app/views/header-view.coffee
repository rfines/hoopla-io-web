View = require 'views/base/view'
template = require 'templates/header'

module.exports = class HeaderView extends View
  autoRender: true
  className: 'header'
  region: 'header'
  template: template
  events:
    "click a.logout" : "logout"

  logout:(e)->
    e.preventDefault()
    $.removeCookie('token')
    $.removeCookie('user')
    window.location = '/'