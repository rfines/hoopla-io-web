Events = require 'models/events'
Event = require 'models/event'

describe 'Events Collection', ->
  beforeEach ->
    @collection = new Events()
    @collection.add new Event()
    @collection.add new Event()

  afterEach ->
    @collection.dispose()

  it 'should give upcoming events when asked', (done) ->
    @collection.at(0).set 'occurrences', [moment().add('days',2).toDate().toISOString()]
    @collection.at(1).set 'occurrences', [moment().subtract('days',2).toDate().toISOString()]
    @collection.upcomingEvents().length.should.be.equal 1
    done()

  it 'should give past events when asked', (done) ->
    @collection.at(0).set 'occurrences', [moment().add('days',2).toDate().toISOString()]
    @collection.at(1).set 'occurrences', [moment().subtract('days',2).toDate().toISOString()]
    @collection.pastEvents().length.should.be.equal 1
    done()   

  it 'should give view events without occurrences as being in the past', (done) ->
    @collection.at(0).set 'occurrences', []
    @collection.pastEvents().length.should.be.equal 2
    @collection.upcomingEvents().length.should.be.equal 0
    done()        