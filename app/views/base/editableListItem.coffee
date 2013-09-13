ListItemView = require 'views/base/listItem'

module.exports = class EditableListItem extends ListItemView
  attach: =>
    super()
    @delegate 'show.bs.collapse', =>
      @publishEvent "emptyNew"
      @subview 'inlineEdit', new @EditView({container: @$el.find('.inlineEdit'), model : @model, collection : @collection}) if not @subview('inlineEdit')
    @delegate 'hide.bs.collapse', =>
      @$el.find('.panel-heading').removeClass('expanded')
    @delegate 'click', '.inlineEditButton', =>
      @$el.find('.panel-heading').addClass('expanded')
      @$el.find('.inlineEdit').show()
      @publishEvent "emptyNew"
      @publishEvent "closeOthers"
    @subscribeEvent "#{@noun}:#{@model.id}:edit:close", =>
      $("#collapse#{@model.id}").collapse('hide')
      @removeSubview 'inlineEdit'
    @subscribeEvent "closeOthers", =>
      panels = $(".panel-collapse.in")
      console.log panels
      _.each panels, (element, index,list)=>
        $('#'+element.id).collapse('hide')
      @removeSubview 'inlineEdit'
    @delegate "click", ".duplicateButton", =>
      @publishEvent "#{@noun}:duplicate", @model        