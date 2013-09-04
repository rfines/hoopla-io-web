ListItemView = require 'views/base/listItem'
RecurrenceList = require 'views/event/recurrenceList'
EventEdit = require 'views/event/edit'

module.exports = class ListItem extends ListItemView
  template: require 'templates/event/listItem'
  noun : "event"    

  getTemplateData: =>
    td = super()
    td.dateText = @model.dateDisplayText()
    td.businessName = Chaplin.datastore.business.get(@model.get('business')).get('name')
    td.isRecurring = @model.get('schedules')?.length > 0
    td  

  attach: =>
    super()
    @delegate 'show.bs.collapse', ->
      @subview 'recurrenceList', new RecurrenceList({container: @$el.find('.recurrenceList'), model: @model}) if not @subview('recurrenceList')
      @subview 'inlineEdit', new EventEdit({container: @$el.find('.inlineEdit'), model : @model, collection : @collection}) if not @subview('inlineEdit')
    @delegate 'click', '.showOccurrences', ->
      @$el.find('.recurrenceList').show()
      @$el.find('.inlineEdit').hide()
    @delegate 'click', '.inlineEditButton', ->
      @$el.find('.recurrenceList').hide()
      @$el.find('.inlineEdit').show()