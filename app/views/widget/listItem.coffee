EditableListItem = require 'views/base/editableListItem'
EditView = require 'views/widget/edit'

module.exports = class ListItem extends EditableListItem
  template: require 'templates/widget/listItem'
  noun : "widget"    
  EditView : EditView