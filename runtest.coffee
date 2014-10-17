Mocha = require 'mocha'
require './lib/mocha-gwt'
mocha = new Mocha
  reporter: 'spec'
  ui: 'mocha-gwt'

mocha.addFile './test/e2e/mocha-gwt.coffee'

mocha.run (failures) ->
  process.on 'exit', ->
    process.exit failures
