path    = require 'path'
{spawn} = require 'child_process'

glob    = require 'glob'

CommandRunnerConfiguration = require './command-runner-configuration'

module.exports =

# Internal: Finds the correct test command to run based on what "file" it can
# find in the project root.
class CommandRunner

  # Internal: Initialize the command runner with the views for rendering the
  # output.
  #
  # @testStatus - A space-pen outlet for the test status icon element.
  # @testStatusView - A space-pen view for the test status output element.
  constructor: (@testStatus, @testStatusView) ->

  # Internal: Run the test command based on configuration priority.
  #
  # Returns nothing.
  run: ->
    return unless atom.project.path?

    cfg = atom.config.get('test-status')
    @configuration = new CommandRunnerConfiguration(cfg)

    return unless @configuration.buildCommand
    @execute()

  # Internal: Execute the command and render the output.
  #
  # cmd - A string of the command to run, including arguments.
  #
  # Returns nothing.
  execute: ->
    @testStatus.removeClass('success fail').addClass('pending')

    cmd = @configuration.buildCommand.split(' ')

    try
      proc = spawn(cmd.shift(), cmd, cwd: atom.project.path)
      output = ''

      proc.stdout.on 'data', (data) =>
        output += data.toString()
        @testStatusView.update(output)

      proc.stderr.on 'data', (data) =>
        output += data.toString()
        @testStatusView.update(output)

      proc.on 'close', (code) =>
        @testStatusView.update(output)

        if code is 0
          atom.emit 'test-status:success'
          @testStatus.removeClass('pending fail').addClass('success')
        else
          atom.emit 'test-status:fail'
          @testStatus.removeClass('pending success').addClass('fail')
    catch err
      @testStatus.removeClass('pending success').addClass('fail')
      @testStatusView.update('An error occured while attempting to run the test command')
