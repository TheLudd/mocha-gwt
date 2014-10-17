chai = require 'chai'
chai.should()
descibeFunction = require '../../lib/describe-function'

describe 'describeFunction', ->

  description = (des) -> from: (fn) -> descibeFunction(fn).should.equal des
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
    description('a + b').from ->
      console.log foo
      a + b
