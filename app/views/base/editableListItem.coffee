ListItemView = require 'views/base/listItem'

module.exports = class EditableListItem extends ListItemView
  collapsedId : undefined
  autoRender: false

  attach: =>
    super()
    @delegate 'show.bs.collapse', =>
      @subview 'inlineEdit', new @EditView({container: @$el.find('.inlineEdit'), model : @model, collection : @collection}) if not @subview('inlineEdit')
      @$el.find('div.panel-heading').addClass('expanded')
      @collapsedId = undefined
    @delegate 'hide.bs.collapse', =>
      @$el.find('div.expanded').removeClass('expanded')
      @collapsedId = @model.id
      @removeSubview 'inlineEdit'
    @delegate 'click', '.inlineEditButton', =>
      @publishEvent "closeOthers"
      @$el.find('.inlineEdit').show()  
    @subscribeEvent "#{@noun}:#{@model.id}:edit:close", =>
      $("#collapse#{@model.id}").collapse('hide')
      @removeSubview 'inlineEdit'
      @render()
    @subscribeEvent "closeOthers", =>
      panels = $(".panel-collapse.in")
      _.each panels, (element, index,list)=>
        $('#'+element.id).collapse('hide')
      @removeSubview 'inlineEdit'
    @delegate "click", ".duplicateButton", =>
      @publishEvent "#{@noun}:duplicate", @model        