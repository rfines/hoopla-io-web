ListView = require 'views/base/list'

module.exports = class EditableList extends ListView

  attach: =>
    super
    @$el.find('.listAlert').hide()

  create: (e) =>
    @hideInitialStage()
    Chaplin.datastore.loadEssential 
      success: =>    
        @subview("newItem", new @EditView({container: @$el.find('.newItem'),collection : @collection,model : new @Model()}))
  
  duplicate: (data) =>
    n = data.clone()
    @subview('newItem', new @EditView({container: @$el.find('.newItem'), collection : @collection, model : n}))  