ListItemView = require 'views/base/listItem'
RecurrenceList = require 'views/event/recurrenceList'
EditView = require 'views/event/edit'
ImageUtils = require 'utils/imageUtils'

module.exports = class ListItem extends ListItemView
  template: require 'templates/event/listItem'
  noun : "event"  
  EditView : EditView
  collapsedId = undefined

  getTemplateData: =>
    td = super()
    td.dateText = @model.dateDisplayText()
    td.startTimeText = "#{@model.nextOccurrence()?.format("h:mm A")} - #{@model.nextOccurrenceEnd()?.format("h:mm A")}"
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

  render: =>
    console.log 'called render in eventListItem'
    super()

  attach: =>
    super()
    @delegate 'show.bs.collapse', =>
      @subview 'inlineEdit', new @EditView({container: @$el.find('.inlineEdit'), model : @model, collection : @collection}) if not @subview('inlineEdit')
      @$el.find('div.panel-heading').addClass('expanded')
    @delegate 'hide.bs.collapse', =>
      @$el.find('div.panel-heading').removeClass('expanded')
      @removeSubview 'inlineEdit'
    @delegate 'click', '.inlineEditButton', =>
      @publishEvent "closeOthers"    
      @$el.find('.inlineEdit').show()  
    @subscribeEvent "#{@noun}:#{@model.id}:edit:close", =>
      $("#collapse#{@model.id}").collapse('hide')
      @removeSubview 'inlineEdit'
    @subscribeEvent "closeOthers", =>
      panels = $(".panel-collapse.in")
      _.each panels, (element, index,list)=>
        $('#'+element.id).collapse('hide')
      @removeSubview 'inlineEdit'
    @delegate "click", ".duplicateButton", =>
      @publishEvent "#{@noun}:duplicate", @model
    @$el.find('.scheduleText').popover(
      trigger: 'hover'
      placement: 'bottom'
      content: @model.get('scheduleText')
    )           
      
