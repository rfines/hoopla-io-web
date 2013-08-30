ListItemView = require 'views/base/listItem'
template = require 'templates/business/listItem'

module.exports = class ListItem extends ListItemView
  template: template
  noun : "business"