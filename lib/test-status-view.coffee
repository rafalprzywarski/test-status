{View} = require 'atom-space-pen-views'

Convert = require 'ansi-to-html'

module.exports =
# Internal: A tool-panel view for the test result output.
class TestStatusView extends View

  # Internal: Initialize test-status output view DOM contents.
  @content: ->
    @div tabIndex: -1, class: 'test-status-output tool-panel panel-bottom padded native-key-bindings', =>
      @div class: 'test-status icon icon-x fail hidden', outlet: 'killTestIcon', click: 'killTest'
      @div class: 'block', =>
        @div class: 'message', outlet: 'testStatusOutput'

  # Internal: Initialize the test-status output view and event handlers.
  initialize: ->
    @output = "<strong>No output</strong>"
    @testStatusOutput.html(@output).css('font-size', "#{atom.config.get('editor.fontSize')}px")

    atom.commands.add 'atom-workspace',
      'test-status:toggle-output': => @toggle()

  createFileLink: (fileLine, links) ->
    links.push fileLine
    return "<a href='#'>#{fileLine}</a>";
  removeDuplicates = (a) ->
    res = {}
    res[a[index]] = a[index] for index in [0..a.length-1]
    value for index, value of res

  attachLinks: (links) ->
    for link in links
      do (link) =>
        @testStatusOutput.find("a:contains('#{link}')").click( =>
          pathAndLine = link.split(":")
          row = parseInt(pathAndLine[1], 10) - 1
          column = parseInt(pathAndLine[2], 10) - 1 if pathAndLine[2]
          p = atom.workspace.open(pathAndLine[0])
          p.then((editor) ->
            editor.setCursorBufferPosition([row, column])))

  # Internal: Update the test-status output view contents.
  #
  # output - A string of the test runner results.
  #
  # Returns nothing.
  update: (output) ->
    @convert ?= new Convert({newline: true})
    links = []
    @output = @convert.toHtml(
      output.replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/([\.\/]?\/?([\w\.\+]+\/)+[\w\.\+]+):(\d+)(:\d+)?/g, (match) => @createFileLink(match, links))
      )
    links = removeDuplicates(links)
    @testStatusOutput.html("<pre>#{@output.trim()}</pre>")
    @testStatusOutput.scrollTop(@testStatusOutput[0].scrollHeight)
    @attachLinks(links)

  # Internal: Detach and destroy the test-status output view.
  #
  # Returns nothing.
  destroy: ->
    @detach()

  # Internal: Toggle the visibilty of the test-status output view.
  #
  # Returns nothing.
  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspace.addBottomPanel(item: this)

  killTest: ->
    @killTestIcon.addClass('hidden')
    @commandRunner.killProcess()

  showKillIcon: ->
    @killTestIcon.removeClass('hidden')

  hideKillIcon: ->
    @killTestIcon.addClass('hidden')

  setCommandRunner: (commandRunner) ->
    @commandRunner = commandRunner
