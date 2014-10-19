chai = require 'chai'
chai.should()
descibeFunction = require '../../lib/describe-function'

describe 'describeFunction', ->

  description = (des) -> from: (fn, thisObj) ->
    descibeFunction(fn, thisObj).should.equal des
  empty = description('')

  it 'should return an empty string for undefined input', ->
    empty.from undefined

  it 'should return an empty string for null input', ->
    empty.from null

  it 'should return an emptu string for an empty function', ->
    empty.from ->

  it 'should return the only line in a one line function, removing return and ;', ->
    description('1').from -> 1

  it 'should return the last line from a multi line function', ->
    description('a + b + c').from ->
      console.log foo
      a + b + c

  it 'should evaluate the variables when the last statement is a condition', ->
    description('1 === 1').from((-> @value == 1), value: 1)

  it 'should handle non evaluatable values', ->
    description('a + b').from -> a + b
