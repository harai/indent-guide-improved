RowMap = require '../lib/row-map'

its = (f) ->
  it f.toString(), f

describe "RowMap", ->
  rowMap = null
  setRowMap = ->
    rowMap = new RowMap Array.prototype.slice.call(arguments).map (item) ->
      bufferRows: item[0]
      screenRows: item[1]

  describe "firstBufferRowForBufferRow", ->
    describe "simplest", ->
      beforeEach ->
        setRowMap([3, 3], [1, 3], [3, 1], [2, 2])

      its -> expect(rowMap.firstScreenRowForBufferRow(0)).toBe(0)
      its -> expect(rowMap.firstScreenRowForBufferRow(1)).toBe(1)
      its -> expect(rowMap.firstScreenRowForBufferRow(2)).toBe(2)
      its -> expect(rowMap.firstScreenRowForBufferRow(3)).toBe(5)
      its -> expect(rowMap.firstScreenRowForBufferRow(4)).toBe(6)
      its -> expect(rowMap.firstScreenRowForBufferRow(5)).toBe(6)
      its -> expect(rowMap.firstScreenRowForBufferRow(6)).toBe(6)
      its -> expect(rowMap.firstScreenRowForBufferRow(7)).toBe(7)
      its -> expect(rowMap.firstScreenRowForBufferRow(8)).toBe(8)
      its -> expect(rowMap.firstScreenRowForBufferRow(9)).toBe(8)
      its -> expect(rowMap.firstScreenRowForBufferRow(10)).toBe(8)
