path    = require 'path'
glob    = require 'glob'

module.exports =

class CommandRunnerConfiguration
  constructor: (@cfg) ->
    @buildCommand = null
    @parseConfiguration(cfg)

  hasLiveUpdate: ->
    return @cfg['live-update'] == true

  isOption: (key) ->
    return key == 'live-update'

  matchBuildCommand: (file) ->
    pattern = path.join(atom.project.path, file)
    matches = glob.sync(pattern)
    return null if matches.length == 0
    return @cfg[file]

  parseConfiguration: ->
    for key in Object.keys(@cfg)
      continue if @isOption(key)
      @buildCommand = @matchBuildCommand(key) unless @buildCommand
