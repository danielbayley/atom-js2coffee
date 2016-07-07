module.exports =
  package: require './package.json'
  activate: ->
    name: @package.name
    from:
      scopeName: 'source.js'
      #fileTypes: ['[data-name*=".js"]:not([data-name*=json])']
    to: scopeName: 'source.coffee'

    transpile: (source) ->
      {allowUnsafeEval} = require 'loophole'
      {build} = allowUnsafeEval -> require 'js2coffee'
      {code} = build source
      return code
