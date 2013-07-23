template = require 'views/templates/home'
View = require 'views/base/view'
Users = require 'models/users'

module.exports = class HomePageView extends View
  autoRender: true
  className: 'home-page'
  template: template