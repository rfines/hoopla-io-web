View = require 'views/base/view'

module.exports = class ListItem extends View
  autoRender: true
  className: 'row'
  noun : "business"

  events:
    "click .edit" : "edit"
    "click .deleteButton" : "destroy"

  edit: (e) =>
    e.preventDefault()
    @publishEvent '!router:route', "#{@noun}/#{@model.id}"

  destroy: (e) =>
    destroyConfirm = confirm("Delete this #{@noun}?")
    if destroyConfirm
      m = @model
      @collection.remove(@model)
      m.destroy()
      @dispose()   
 