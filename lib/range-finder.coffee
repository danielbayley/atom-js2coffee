{Range} = require 'atom'

# via https://github.com/atom/sort-lines/blob/master/lib/range-finder.coffee

module.exports = class RangeFinder
  # Public
  @rangesFor: (editor) ->
    new RangeFinder(editor).ranges()

  # Public
  constructor: (@editor) ->

  # Public
  ranges: =>
    selectionRanges = @selectionRanges()
    if selectionRanges.length is 0
      [@sortableRangeForEntireBuffer()]
    else
      selectionRanges.map @sortableRangeFrom

  # Internal
  selectionRanges: =>
    selectedRanges = @editor.getSelectedBufferRanges()
    selectedRanges.filter (range) -> not range.isEmpty()

  # Internal
  sortableRangeForEntireBuffer: =>
    @editor.getBuffer().getRange()

  # Internal
  sortableRangeFrom: (selectionRange) =>
    startRow = selectionRange.start.row
    startCol = 0
    endRow = selectionRange.end.row - (if selectionRange.end.column is 0 then 1 else 0)
    endCol = @editor.lineTextForBufferRow(endRow).length
    new Range [startRow, startCol], [endRow, endCol]
