Promise = require 'bluebird'

describe '0', ->
  log = (out) -> -> out == out

  Given -> @foo = 'a'
  When -> console.log 3

  describe '1', ->
    Given -> Promise.resolve('bar').then (@fromGiven) =>
    When -> Promise.resolve('foo').then (fromWhen) => @result = fromWhen + @fromGiven
    Then -> @result == 'foobar'

    describe '2', ->
      Given -> 'a2'
      When -> 'b2'
      Then -> 'c2'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'
      And -> 'c2+'

    describe '3', ->
      Given -> 'a2-2'
      When -> 'b2-2'
      Then -> 'c2-2'
      And -> 'c2-2+'

  describe '4', ->

