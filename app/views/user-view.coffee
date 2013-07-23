View = require 'views/base/view'
template = require 'views/templates/users/user-item'

module.exports = class HeaderView extends View
  autoRender: true
  template: template
