Event = require 'models/event'

describe 'Event Model', ->
  beforeEach ->
    @model = new Event({_id : 1})

  afterEach ->
    @model.dispose()

  it 'should get the next occurrence', (done) ->
    @model.set 'occurrences', ['2013-08-30T17:30:00.000Z']
    m = moment('2013-08-30T17:30:00.000Z')
    @model.nextOccurrence().should.be.eql m
    done()

  it 'should say today if the next occurrence is today', (done) ->
    @model.set 'occurrences', [moment().toDate().toISOString()]
    @model.nextOccurrenceText().should.be.equal "Today"
    done()  

  it 'should say Tomorrow if the next occurrence is tomorrow', (done) ->
    @model.set 'occurrences', [moment().add('days',1).toDate().toISOString()]
    @model.nextOccurrenceText().should.be.equal "Tomorrow"
    done()    

  it 'should use the date if the next occurrence is further away than tomorrow', (done) ->
    next = moment().add('days',3)
    @model.set 'occurrences', [next.toDate().toISOString()]
    @model.nextOccurrenceText().should.be.equal next.format('MM/DD/YYYY')
    done()        

  it 'should get the start date from fixed occurrences if available', (done) ->
    start = moment().add('days',3)
    @model.set 'fixedOccurrences', [{start : start.toDate().toISOString()}]
    @model.getStartDate().toDate().should.be.eql start.toDate()
    done()

  it 'should get the end date from fixed occurrences if available', (done) ->
    end = moment().add('days',3)
    @model.set 'fixedOccurrences', [{end : end.toDate().toISOString()}]
    @model.getEndDate().toDate().should.be.eql end.toDate()
    done()    