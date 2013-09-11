Business = require 'models/business'

describe 'Business Model', ->
  beforeEach ->
    @model = new Business({_id : 1})

  afterEach ->
    @model.dispose()

  it 'should replace the facebook url with a new one', (done)->
    @model.set 'socialMediaLinks', [{target:'Facebook', url:'http:facebook.com/'}]
    @model.addFacebookLink('http://facebok.com/blah')
    @model.get('socialMediaLinks').length.should.be.equal 1
    @model.get('socialMediaLinks')[0].url.should.be.equal 'http://facebok.com/blah'
    done()
  it 'should replace the twitter url with a new one', (done)->
    @model.set 'socialMediaLinks', [{target:'Twitter', url:'http:twitter.com/'}]
    @model.addTwitterLink('http://twitter.com/blah')
    @model.get('socialMediaLinks').length.should.be.equal 1
    @model.get('socialMediaLinks')[0].url.should.be.equal 'http://twitter.com/blah'
    done()
  it 'should replace the foursquare url with a new one', (done)->
    @model.set 'socialMediaLinks', [{target:'Foursquare', url:'http:foursquare.com/'}]
    @model.addFoursquareLink('http://foursquare.com/blah')
    @model.get('socialMediaLinks').length.should.be.equal 1
    @model.get('socialMediaLinks')[0].url.should.be.equal 'http://foursquare.com/blah'
    done()