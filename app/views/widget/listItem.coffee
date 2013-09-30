EditableListItem = require 'views/base/editableListItem'
EditView = require 'views/widget/edit'

module.exports = class ListItem extends EditableListItem
  template: require 'templates/widget/listItem'
  noun : "widget"    
  EditView : EditView

  attach:()=>
    super
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