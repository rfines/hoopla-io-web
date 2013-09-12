ListItemView = require 'views/base/listItem'

module.exports = class EditableListItem extends ListItemView
  attach: =>
    super()
    @delegate 'show.bs.collapse', =>
      @subview 'inlineEdit', new @EditView({container: @$el.find('.inlineEdit'), model : @model, collection : @collection}) if not @subview('inlineEdit')
    @delegate 'hide.bs.collapse', =>
      @$el.find('.panel-heading').removeClass('expanded')
    @delegate 'click', '.inlineEditButton', =>
      console.log "inside delegate"
      @$el.find('.panel-heading').addClass('expanded')
      @$el.find('.inlineEdit').show()
    @subscribeEvent "#{@noun}:#{@model.id}:edit:close", =>
      $("#collapse#{@model.id}").collapse('hide')
      @removeSubview 'inlineEdit'
    @delegate "click", ".duplicateButton", =>
      @publishEvent "#{@noun}:duplicate", @model        