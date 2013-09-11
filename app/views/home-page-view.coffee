template = require 'templates/home'
View = require 'views/base/view'
Users = require 'models/users'
ImageChooser = require 'views/common/imageChooser'

module.exports = class HomePageView extends View
  autoRender: true
  className: 'home-page'
  template: template
