ListItemView = require 'views/base/listItem'
RecurrenceList = require 'views/event/recurrenceList'
EditView = require 'views/event/edit'
ImageUtils = require 'utils/imageUtils'

module.exports = class ListItem extends ListItemView
  template: require 'templates/event/listItem'
  noun : "event"  
  EditView : EditView

  getTemplateData: =>
    td = super()
    td.dateText = @model.dateDisplayText()
    td.startTimeText = "#{@model.nextOccurrence().format("h:mm A")} - #{@model.nextOccurrenceEnd().format("h:mm A")}"
    if @model.get('media')?.length >0
      td.imageUrl =$.cloudinary.url(ImageUtils.getId( @model.get('media')[0]?.url), {crop: 'fill', height: 100, width: 125})
    else
      td.imageUrl = ""
    td.businessName = Chaplin.datastore.business.get(@model.get('business')).get('name')
    if Chaplin.datastore.business.get(@model.get('business')).get('promotionTargets').length <= 0
      td.allowPromotion = false
    else
      td.allowPromotion = true
    td.isRecurring = @model.get('schedules')?.length > 0
    td  

  attach: =>
    super()
    @delegate 'show.bs.collapse', =>
      @subview 'recurrenceList', new RecurrenceList({container: @$el.find('.recurrenceList'), model: @model}) if not @subview('recurrenceList')
      @subview 'inlineEdit', new @EditView({container: @$el.find('.inlineEdit'), model : @model, collection : @collection}) if not @subview('inlineEdit')
    @delegate 'hide.bs.collapse', =>
      @$el.find('.panel-heading').removeClass('expanded')
    @delegate 'click', '.showOccurrences', =>
      @$el.find('.recurrenceList').show()
      @$el.find('.inlineEdit').hide()
    @delegate 'click', '.inlineEditButton', =>
      @$el.find('.panel-heading').addClass('expanded')
      @$el.find('.recurrenceList').hide()
      @$el.find('.inlineEdit').show()
    @subscribeEvent "event:#{@model.id}:edit:close", =>
      $("#collapse#{@model.id}").collapse('hide')
      @removeSubview 'recurrenceList'
      @removeSubview 'inlineEdit'
    @delegate "click", ".duplicateButton", =>
      @publishEvent 'event:duplicate', @model
    @subscribeEvent "closeOthers", =>
      panels = $(".panel-collapse.in")
      _.each panels, (element, index,list)=>
        $('#'+element.id).collapse('hide')
      @removeSubview 'inlineEdit'
