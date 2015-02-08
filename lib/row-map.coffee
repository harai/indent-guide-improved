{Point} = require 'atom'

class RowMap
  constructor: (regions) ->
    @regions = regions

  firstScreenRowForBufferRow: (row) ->
    bufAcc = -1
    scrAcc = -1
    for reg in @regions
      if reg.bufferRows is 1 or reg.screenRows is 1
        bufAcc += reg.bufferRows
        scrAcc += reg.screenRows
        if row <= bufAcc
          break
        continue
      if reg.bufferRows is reg.screenRows
        if row <= bufAcc + reg.bufferRows
          diff = row - bufAcc
          bufAcc += diff
          scrAcc += diff
          break
        bufAcc += reg.bufferRows
        scrAcc += reg.screenRows
        continue
      throw "illegal state"
    # bufAcc < row is permitted
    scrAcc

module.exports = RowMap
