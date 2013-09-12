Model = require 'models/base/model'

module.exports = class Widget extends Model
  
  urlRoot : "/api/widget"

  defaults: 
    height: 350
    width: 350
    accentColor: '06A1AF'

  clone: ->
    json = @toJSON()
    delete json.id
    delete json._id
    delete json._v
    return new Widget(json)  