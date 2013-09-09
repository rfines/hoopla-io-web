require 'lib/view-helper' # Just load the view helpers, no return value

module.exports = class View extends Chaplin.View
  autoRender: true
  
  initialize: ->
    super
    @modelBinder = new Backbone.ModelBinder()

  # Precompiled templates function initializer.
  getTemplateFunction: ->
    @template
