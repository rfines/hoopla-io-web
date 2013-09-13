ListView = require 'views/base/list'

module.exports = class EditableList extends ListView

  attach: =>
    super
    @$el.find('.listAlert').hide()
    @subscribeEvent 'closeOthers',=>
      @removeSubview 'newItem' if @subview 'newItem'
      console.log "Should have emptied the new item view"

  create: (e) =>
    Chaplin.datastore.loadEssential 
      success: =>    
        @subview("newItem", new @EditView({container: @$el.find('.newItem'),collection : @collection,model : new @Model()}))

  showCreatedMessage: (data) =>
    @$el.find('.listAlert').show()
    @$el.find('.listAlert').html("Your #{@noun} has been created. <a href='##{data.id}'>View</a>")      

  duplicate: (data) =>
    n = data.clone()
    @subview('newItem', new EventEdit({container: @$el.find('.newItem'), collection : @collection, model : n}))  