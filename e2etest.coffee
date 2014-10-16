Promise = require 'bluebird'

describe '0', ->
  log = (out) -> -> #console.log out

  Given log 'a'
  When log 'b'
  Then log 'c'
  Invariant log 'I'

  describe '1', ->
    Given log 'a1'
    When log 'b1'
    Then log 'c1'
    And log 'c1+'

    describe '2', ->
      Given log 'a2'
      When log 'b2'
      Then log 'c2'
      And log 'c2+'

    describe '3', ->
      Given log 'a2-2'
      When log 'b2-2'
      Then log 'c2-2'
      And log 'c2-2+'

  describe '4', ->

