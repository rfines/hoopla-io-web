Event = require 'models/event'

describe 'Event Model', ->
  beforeEach ->
    @model = new Event({_id : 1})

  afterEach ->
    @model.dispose()

  it 'should get the next occurrence', (done) ->
    m = moment().add('days',2)
    @model.set 'occurrences', [m.toDate().toISOString()]
    @model.nextOccurrence().toDate().should.be.eql m.toDate()
    done()

  it 'should return undefined if there are no occurrences', (done) ->
    expect(@model.nextOccurrence()).to.not.exist
    done()

  it 'should return undefined if all occurrences are past', (done) ->
    m = moment().subtract('days',2)
    @model.set 'occurrences', [m.toDate().toISOString()]
    expect(@model.nextOccurrence()).to.not.exist
    @model.dateDisplayText().should.be.equal m.format('MM/DD/YYYY')
    done()

  it 'should return the last occurrence', (done) ->
    m = moment().add('days',2)
    m2 = moment().add('days',3)
    @model.set 'occurrences', [m.toDate().toISOString(), m2.toDate().toISOString()]
    @model.lastOccurrence().toDate().should.be.eql m2.toDate()
    done()  

  it 'should return the last occurrence when no occurrences are scheduled', (done) ->
    m = moment().add('days',2)
    m2 = moment().add('days',3)
    @model.set 'fixedOccurrences', [{end: m.toDate().toISOString()}, {end: m2.toDate().toISOString()}]
    @model.lastOccurrence().toDate().should.be.eql m2.toDate()
    done() 

  it 'should return the last occurrence when no occurrences or fixed occurences are scheduled', (done) ->
    m = moment().add('days',2)
    @model.set 'schedules', [{end: m.toDate().toISOString()}]
    @model.lastOccurrence().toDate().should.be.eql m.toDate()
    done()          

  it 'should say today if the next occurrence is today', (done) ->
    @model.set 'occurrences', [moment().toDate().toISOString()]
    @model.dateDisplayText().should.be.equal "Today"
    done()  

  it 'should say Tomorrow if the next occurrence is tomorrow', (done) ->
    @model.set 'occurrences', [moment().add('days',1).toDate().toISOString()]
    @model.dateDisplayText().should.be.equal "Tomorrow"
    done()    

  it 'should use the date if the next occurrence is further away than tomorrow', (done) ->
    next = moment().add('days',3)
    @model.set 'occurrences', [next.toDate().toISOString()]
    @model.dateDisplayText().should.be.equal next.format('MM/DD/YYYY')
    done()        

  it 'should get the start date from fixed occurrences if available', (done) ->
    start = moment().add('days',3)
    @model.set 'occurrences', [{start : start.toDate().toISOString()}]
    @model.getStartDate().toDate().should.be.eql start.toDate()
    done()

  it 'should get the end date from fixed occurrences if available', (done) ->
    end = moment().add('days',3)
    @model.set 'occurrences', [{end : end.toDate().toISOString()}]
    @model.getEndDate().toDate().should.be.eql end.toDate()
    done()    