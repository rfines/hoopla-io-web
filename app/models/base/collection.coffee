Model = require 'models/base/model'

module.exports = class Collection extends Chaplin.Collection
  model: Model

  fetch: (options) ->
    options.beforeSend = (xhr) ->
      if($.coookie('token')){
        xhr.setRequestHeader('X-AuthToken', $.cookie('token'))
      }
    super(options)
  
