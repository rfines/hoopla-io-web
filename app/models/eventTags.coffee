Collection = require 'models/base/collection'

module.exports = class EventTags extends Collection
  model : Chaplin.Model
  url: ->
    "/api/eventTag"

  comparator : (tag) ->
    tag.get('text').toLowerCase()    