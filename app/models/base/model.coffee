module.exports = class Model extends Chaplin.Model
  idAttribute: "_id"
  fetch: (options) ->
    options.beforeSend = (xhr) ->
      if $.cookie('token')
        xhr.setRequestHeader('X-AuthToken', $.cookie('token'))
    super(options)  

  save: (fields, options) ->
    @publishEvent 'startWaiting'
    options = options || {}
    options.beforeSend = (xhr) ->
      if $.cookie('token')
        xhr.setRequestHeader('X-AuthToken', $.cookie('token'))
    super(fields, options)  

  destroy: (options) ->
    options = options || {}
    options.beforeSend = (xhr) ->
      if $.cookie('token')
        xhr.setRequestHeader('X-AuthToken', $.cookie('token'))
    super(options)          