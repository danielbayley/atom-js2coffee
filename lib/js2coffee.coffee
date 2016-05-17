{allowUnsafeEval} = require 'loophole'
Js2Coffee = allowUnsafeEval -> require 'js2coffee'

{MessagePanelView, LineMessageView} = require 'atom-message-panel'

RangeFinder = require './range-finder'
messages = null

createMessagePanelView = ->
  new MessagePanelView
    title: 'js2coffee'
    recentMessagesAtTop: true

warningLine = (range, e) ->
  new LineMessageView
    line: range.start.row + e.start.line
    character: e.start.column
    message: "warning: #{e.description}"

errorLine = (range, e) ->
  new LineMessageView
    line: range.start.row + e.start.line
    character: e.start.column
    message: "error: #{e.message}"
    preview: e.sourcePreview

module.exports =
  activate: ->
    @commands = atom.commands.add 'atom-workspace',
      'js2coffee:convert': (e) ->
        editor = atom.workspace.getActiveTextEditor()
        convertJs editor
      'js2coffee:messages': (e) ->
        if messages.panel?.isVisible()
          messages.close()
        else
          messages.attach()
    messages = createMessagePanelView()

  deactivate: ->
    @commands.dispose()
    messages?.close()
    messages = null

  convert: convertJs = (editor) ->
    messages.clear()
    ranges = RangeFinder.rangesFor editor
    ranges.forEach (range) ->
      content = editor.getTextInBufferRange range
      try
        result = Js2Coffee.build content,
          indent: editor.getTabText()
          filename: editor.getTitle()
      catch e
        console.error 'invalid javascript: %s', e.message
        messages.add errorLine range, e

      if result?.warnings
        result.warnings.forEach (e) ->
          messages.add warningLine range, e
      if result?.code
        editor.setTextInBufferRange range, result.code
    if not messages.panel?.isVisible() and messages.messages.length
      messages.attach()
