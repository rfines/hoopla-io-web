View = require 'views/base/view'
template = require 'templates/business/listItem'

module.exports = class ListItem extends View
  autoRender: true
  template: template
  className: 'row'