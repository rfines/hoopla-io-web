View = require 'views/base/view'
template = require 'templates/topNav'

module.exports = class TopNav extends View
  className: 'topNav'
  region: 'topNav'
  template: template
