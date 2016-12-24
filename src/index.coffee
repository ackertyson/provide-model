Promise = require 'promise'

class ProvideModel
  # Wrap model methods in ES6 generator function so we can use 'yield' instead
  #  of clunkier Promise.then().catch() (though all methods remain Promise-based
  #  under the hood); also add BASEMODEL properties to provided model.
  constructor: (@BaseModel) ->

  provide: (Model, args...) ->
    Model = @_wrap Model # wrap model methods in ES6 generators
    for name, property of @BaseModel # add static class properties
      Model[name] = property
    for name, property of @BaseModel.prototype # add BaseModel instance properties
      Model.prototype[name] = property
    new Model args...


  _wrap: (Model) ->
    # wrap MODEL instance methods
    _typeof = (subject, type) ->
      Object::toString.call(subject).toLowerCase().slice(8, -1) is type.toLowerCase()

    _yields = (callback) ->
      (args...) ->
        generator = callback.call null, args...
        handle = (result) ->
          return Promise.resolve result.value if result.done
          Promise.resolve(result.value).then (data) ->
            handle generator.next data
          , (err) ->
            handle generator.throw err
        try # initialize CALLBACK to first 'yield' call
          handle generator.next()
        catch ex
          Promise.reject ex

    for name, prop of Model.prototype
      Model.prototype[name] = _yields prop if _typeof prop, 'function'
      if _typeof prop, 'object'
        Model.prototype[name] = prop
        @_wrap prop
    Model


module.exports = ProvideModel
