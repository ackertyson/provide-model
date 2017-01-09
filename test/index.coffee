Model = require '../src/index'

describe 'provide-model', ->
  before (done) ->
    class ModelX
      table:
        name: 'fake'
      methodA: (arg) ->
        yield Promise.resolve "AX #{arg}"
      methodB: (arg) ->
        yield @methodA "B #{arg}"
      methodC: (arg) ->
        yield Promise.reject new Error "C #{arg}"
    class ModelZ
      table:
        name: 'fake2'
      methodA: (arg) ->
        yield Promise.resolve "AZ #{arg}"
    class ModelY
      @prop: 999
      constructor: (Model) ->
      methodD: (arg) ->
        yield Promise.resolve "A #{arg}"
    @m = new Model ModelY
    @n = new Model ModelY
    @model = @m.provide ModelX
    @modelz = @n.provide ModelZ
    done()

  it 'should add instance properties', ->
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
