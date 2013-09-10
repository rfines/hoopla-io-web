ListView = require 'views/base/list'

module.exports = class EditableList extends ListView

  attach: =>
    super
    @$el.find('.listAlert').hide()

  create: (e) =>
    Chaplin.datastore.loadEssential 
      success: =>    
        @view = new @EditView
          container: @$el.find('.newItem')
          collection : @collection
          model : new @Model()              

  showCreatedMessage: (data) =>
    @$el.find('.listAlert').show()
    @$el.find('.listAlert').html("Your #{@noun} has been created. <a href='##{data.id}'>View</a>")      

  duplicate: (data) =>
    n = data.clone()
    new @EditView
      container: @$el.find('.newItem')
      collection : @collection
      model : n      