Promise = require 'bluebird'

describe 'main', ->
  log = (out) -> -> out == out

  Given -> @foo = 'a'
  When -> console.log 'when'

  describe 'first', ->
    Given -> Promise.resolve('bar').then (@fromGiven) =>
    When -> Promise.resolve('foo').then (fromWhen) => @result = fromWhen + @fromGiven
    Then -> @result == 'foobar'

    describe 'second', ->
      Given -> 'a2'
      When -> 'b2'
      Then -> 'c2'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'

    describe 'third', ->
      Given -> 'a2-2'
      When -> 'b2-2'
      Then -> 'c2-2'
      And -> 'c2-2+'

  describe 'fourth', ->

