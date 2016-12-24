Model = require '../src/index'

describe 'Model', ->
  before (done) ->
    class ModelX
      methodA: (arg) ->
        yield Promise.resolve "A #{arg}"
      methodB: (arg) ->
        yield @methodA "B #{arg}"
      methodC: (arg) ->
        yield Promise.reject new Error "C #{arg}"
    class ModelY
      @prop: 999
      constructor: (@value, other) ->
        console.log 'ctor y'
      methodD: (arg) ->
        yield Promise.resolve "A #{arg}"
    @m = new Model ModelY
    @model = @m.provide ModelX, 'fake'
    done()

  describe 'provide', ->
    it 'should add class and instance properties', ->
      @model.should.have.property 'methodA'
      @model.should.have.property 'methodD'
      @model.constructor.should.have.property 'prop', 999

    it 'should allow model methods to see each other', ->
      @model.methodB('one').then (data) ->
        console.log "yeah", data
      .catch (err) ->
        console.log "nope", err
