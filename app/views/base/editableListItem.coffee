ListItemView = require 'views/base/listItem'

module.exports = class EditableListItem extends ListItemView
  attach: =>
    super()
    @delegate 'show.bs.collapse', =>
      @subview 'inlineEdit', new @EditView({container: @$el.find('.inlineEdit'), model : @model, collection : @collection}) if not @subview('inlineEdit')
    @delegate 'hide.bs.collapse', =>
      console.log "hide bs collapse"
      console.log @$el.find('div.panel-heading')
      @$el.find('div.panel-heading').removeClass('expanded')
    @delegate 'click', '.inlineEditButton', =>
      @publishEvent "closeOthers"
      @$el.find('.panel-heading').addClass('expanded')
      @$el.find('.inlineEdit').show()
      
    @subscribeEvent "#{@noun}:#{@model.id}:edit:close", =>
      $("#collapse#{@model.id}").collapse('hide')
      @removeSubview 'inlineEdit'
    @subscribeEvent "closeOthers", =>
      panels = $(".panel-collapse.in")
      _.each panels, (element, index,list)=>
        $('#'+element.id).collapse('hide')
        $('#'+element.id+'>.panel-heading')
      @removeSubview 'inlineEdit'
    @delegate "click", ".duplicateButton", =>
      @publishEvent "#{@noun}:duplicate", @model        