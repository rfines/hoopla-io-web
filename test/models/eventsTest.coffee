Events = require 'models/events'
Event = require 'models/event'

describe 'Events Collection', ->
  beforeEach ->
    @collection = new Events()
    @collection.add new Event()
    @collection.add new Event()

  afterEach ->
    @collection.dispose()