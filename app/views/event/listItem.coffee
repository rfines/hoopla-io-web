ListItemView = require 'views/base/listItem'

module.exports = class ListItem extends ListItemView
  template: require 'templates/event/listItem'
  noun : "event"    

  getTemplateData: =>
    td = super()
    td.dateText = @model.nextOccurrenceText()
    td.businessName = Chaplin.datastore.business.get(@model.get('business')).get('name')
    td  