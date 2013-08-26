View = require 'views/base/view'

module.exports = class Basic extends View
  autoRender: true
  container: "page-container"

  initialize: (options) ->
    @template = options.template
    super(options)