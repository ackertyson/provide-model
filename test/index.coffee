Model = require '../src/index'

describe 'provide-model', ->
  before (done) ->
    class ModelX
      methodA: (arg) ->
        yield Promise.resolve "AX #{arg}"
      methodB: (arg) ->
        yield @methodA "B #{arg}"
      methodC: (arg) ->
        yield Promise.reject new Error "C #{arg}"
    class ModelZ
      methodA: (arg) ->
        yield Promise.resolve "AZ #{arg}"
    class ModelY
      @prop: 999
      constructor: (@value, other) ->
      methodD: (arg) ->
        yield Promise.resolve "A #{arg}"
    @m = new Model ModelY
    @n = new Model ModelY
    @model = @m.provide ModelX, 'fake'
    @modelz = @n.provide ModelZ, 'fake2'
    done()

  it 'should add class and instance properties', ->
    @model.should.have.property 'methodA'
    @model.should.have.property 'methodD'
    @model.constructor.should.have.property 'prop', 999

  it 'should allow model methods to see each other', ->
    @model.methodB('one').then (data) ->
      data.should.equal 'AX B one'
    .catch (err) ->
      expect(err).to.be.null

  it 'should not overwrite methods of same name', ->
    @model.methodA('one').then (data) ->
      data.should.equal 'AX one'
    .catch (err) ->
      expect(err).to.be.null

    @modelz.methodA('one').then (data) ->
      data.should.equal 'AZ one'
    .catch (err) ->
      expect(err).to.be.null
