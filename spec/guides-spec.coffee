gs = require '../lib/guides'
{toGuides, uniq, statesAboveVisible, statesBelowVisible, getGuides} = gs
{Point} = require 'atom'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
its = (f) ->
  it f.toString(), f

fits = (f) ->
  fit f.toString(), f

describe "toGuides", ->
  guides = null
  describe "step-by-step indent", ->
    beforeEach ->
      guides = toGuides([0, 1, 2, 2, 1, 2, 1, 0], [])

    its -> expect(guides.length).toBe(3)
    its -> expect(guides[0].length).toBe(6)
    its -> expect(guides[0].point).toEqual(new Point(1, 0))
    its -> expect(guides[1].length).toBe(2)
    its -> expect(guides[1].point).toEqual(new Point(2, 1))
    its -> expect(guides[2].length).toBe(1)
    its -> expect(guides[2].point).toEqual(new Point(5, 1))

  describe "steep indent", ->
    beforeEach ->
      guides = toGuides([0, 3, 2, 1, 0], [])

    its -> expect(guides.length).toBe(3)
    its -> expect(guides[0].length).toBe(3)
    its -> expect(guides[0].point).toEqual(new Point(1, 0))
    its -> expect(guides[1].length).toBe(2)
    its -> expect(guides[1].point).toEqual(new Point(1, 1))
    its -> expect(guides[2].length).toBe(1)
    its -> expect(guides[2].point).toEqual(new Point(1, 2))

  describe "steep dedent", ->
    guides = null
    beforeEach ->
      guides = toGuides([0, 1, 2, 3, 0], [])

    its -> expect(guides.length).toBe(3)
    its -> expect(guides[0].length).toBe(3)
    its -> expect(guides[0].point).toEqual(new Point(1, 0))
    its -> expect(guides[1].length).toBe(2)
    its -> expect(guides[1].point).toEqual(new Point(2, 1))
    its -> expect(guides[2].length).toBe(1)
    its -> expect(guides[2].point).toEqual(new Point(3, 2))

  describe "recurring indent", ->
    guides = null
    beforeEach ->
      guides = toGuides([0, 1, 1, 0, 1, 0], [])

    its -> expect(guides.length).toBe(2)
    its -> expect(guides[0].length).toBe(2)
    its -> expect(guides[0].point).toEqual(new Point(1, 0))
    its -> expect(guides[1].length).toBe(1)
    its -> expect(guides[1].point).toEqual(new Point(4, 0))

  describe "no indent", ->
    guides = null
    beforeEach ->
      guides = toGuides([0, 0, 0], [])

    its -> expect(guides.length).toBe(0)

  describe "same indent", ->
    guides = null
    beforeEach ->
      guides = toGuides([1, 1, 1], [])

    its -> expect(guides.length).toBe(1)
    its -> expect(guides[0].length).toBe(3)
    its -> expect(guides[0].point).toEqual(new Point(0, 0))

  describe "stack and active", ->
    describe "simple", ->
      beforeEach ->
        guides = toGuides([1, 2, 2, 1, 2, 1, 0], [2])

      its -> expect(guides[0].stack).toBe(true)
      its -> expect(guides[0].active).toBe(false)
      its -> expect(guides[1].stack).toBe(true)
      its -> expect(guides[1].active).toBe(true)
      its -> expect(guides[2].stack).toBe(false)
      its -> expect(guides[2].active).toBe(false)

    describe "cursor not on deepest", ->
      beforeEach ->
        guides = toGuides([1, 2, 1], [0])

      its -> expect(guides[0].stack).toBe(true)
      its -> expect(guides[0].active).toBe(true)
      its -> expect(guides[1].stack).toBe(false)
      its -> expect(guides[1].active).toBe(false)

    describe "no cursor", ->
      beforeEach ->
        guides = toGuides([1, 2, 1], [])

      its -> expect(guides[0].stack).toBe(false)
      its -> expect(guides[0].active).toBe(false)
      its -> expect(guides[1].stack).toBe(false)
      its -> expect(guides[1].active).toBe(false)

    describe "multiple cursors", ->
      beforeEach ->
        guides = toGuides([1, 2, 1, 2, 0, 1], [1, 2])

      its -> expect(guides[0].stack).toBe(true)
      its -> expect(guides[0].active).toBe(true)
      its -> expect(guides[1].stack).toBe(true)
      its -> expect(guides[1].active).toBe(true)
      its -> expect(guides[2].stack).toBe(false)
      its -> expect(guides[2].active).toBe(false)
      its -> expect(guides[3].stack).toBe(false)
      its -> expect(guides[3].active).toBe(false)

  describe "empty lines", ->
    describe "between the same indents", ->
      beforeEach ->
        guides = toGuides([1, null, 1], [])

      its -> expect(guides.length).toBe(1)
      its -> expect(guides[0].length).toBe(3)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))

    describe "starts with a null", ->
      beforeEach ->
        guides = toGuides([null, 1], [])

      its -> expect(guides.length).toBe(1)
      its -> expect(guides[0].length).toBe(2)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))

    describe "starts with nulls", ->
      beforeEach ->
        guides = toGuides([null, null, 1], [])

      its -> expect(guides.length).toBe(1)
      its -> expect(guides[0].length).toBe(3)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))

    describe "ends with a null", ->
      beforeEach ->
        guides = toGuides([1, null], [])

      its -> expect(guides.length).toBe(1)
      its -> expect(guides[0].length).toBe(1)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))

    describe "ends with nulls", ->
      beforeEach ->
        guides = toGuides([1, null, null], [])

      its -> expect(guides.length).toBe(1)
      its -> expect(guides[0].length).toBe(1)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))

    describe "large to small", ->
      beforeEach ->
        guides = toGuides([2, null, 1], [])

      its -> expect(guides.length).toBe(2)
      its -> expect(guides[0].length).toBe(3)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))
      its -> expect(guides[1].length).toBe(1)
      its -> expect(guides[1].point).toEqual(new Point(0, 1))

    describe "small to large", ->
      beforeEach ->
        guides = toGuides([1, null, 2], [])

      its -> expect(guides.length).toBe(2)
      its -> expect(guides[0].length).toBe(3)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))
      its -> expect(guides[1].length).toBe(2)
      its -> expect(guides[1].point).toEqual(new Point(1, 1))

    describe "continuous", ->
      beforeEach ->
        guides = toGuides([1, null, null, 1], [])

      its -> expect(guides.length).toBe(1)
      its -> expect(guides[0].length).toBe(4)
      its -> expect(guides[0].point).toEqual(new Point(0, 0))

  describe "incomplete indent", ->
    guides = null
    beforeEach ->
      guides = toGuides([1, 1.5, 1], [])

    its -> expect(guides.length).toBe(1)
    its -> expect(guides[0].length).toBe(3)
    its -> expect(guides[0].point).toEqual(new Point(0, 0))

describe "uniq", ->
  its -> expect(uniq([1, 1, 1, 2, 2, 3, 3])).toEqual([1, 2, 3])
  its -> expect(uniq([1, 1, 2])).toEqual([1, 2])
  its -> expect(uniq([1, 2])).toEqual([1, 2])
  its -> expect(uniq([1, 1])).toEqual([1])
  its -> expect(uniq([1])).toEqual([1])
  its -> expect(uniq([])).toEqual([])

describe "statesAboveVisible", ->
  run = statesAboveVisible
  guides = null
  rowIndents = null
  getRowIndents = (r) ->
    rowIndents[r]
  getLastRow = () ->
    rowIndents.length - 1

  describe "only stack", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, 3, 2,
        3
      ]
      guides = run([3], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([])

  describe "active and stack", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, 2, 2,
        3
      ]
      guides = run([3], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

  describe "cursor on null row", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, null, 2,
        3
      ]
      guides = run([3], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

  describe "continuous nulls", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, null, null,
        3
      ]
      guides = run([3], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1, 2])
    its -> expect(guides.active).toEqual([2])

  describe "no effect", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, 0, 1,
        3
      ]
      guides = run([2], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([])
    its -> expect(guides.active).toEqual([])

  describe "no rows", ->
    beforeEach ->
      rowIndents = []
      guides = run([], -1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([])
    its -> expect(guides.active).toEqual([])

  describe "no rows above", ->
    beforeEach ->
      rowIndents = [0]
      guides = run([], -1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([])
    its -> expect(guides.active).toEqual([])

  describe "multiple cursors", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, 3, 2,
        3
      ]
      guides = run([2, 3], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

  describe "multiple cursors 2", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, 3, 2,
        3
      ]
      guides = run([1, 2], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([0, 1])

  describe "multiple cursors on the same level", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2, 3, 2,
        3
      ]
      guides = run([2, 4], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

describe "statesBelowVisible", ->
  run = statesBelowVisible
  guides = null
  rowIndents = null
  getRowIndents = (r) ->
    rowIndents[r]
  getLastRow = () ->
    rowIndents.length - 1

  describe "only stack", ->
    beforeEach ->
      rowIndents = [
        3,
        2, 3, 2, 1, 0
      ]
      guides = run([2], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([])

  describe "active and stack", ->
    beforeEach ->
      rowIndents = [
        3,
        2, 2, 2, 1, 0
      ]
      guides = run([2], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

  describe "cursor on null row", ->
    beforeEach ->
      rowIndents = [
        3,
        2, null, 2, 1, 0
      ]
      guides = run([2], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

  describe "continuous nulls", ->
    beforeEach ->
      rowIndents = [
        3,
        null, null, 2
      ]
      guides = run([1], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

  describe "no effect", ->
    beforeEach ->
      rowIndents = [
        3,
        0, 1, 0
      ]
      guides = run([3], 4, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([])
    its -> expect(guides.active).toEqual([])

  describe "no rows", ->
    beforeEach ->
      rowIndents = []
      guides = run([], -1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([])
    its -> expect(guides.active).toEqual([])

  describe "no rows below", ->
    beforeEach ->
      rowIndents = [0]
      guides = run([], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([])
    its -> expect(guides.active).toEqual([])

  describe "multiple cursors", ->
    beforeEach ->
      rowIndents = [
        3,
        2, 3, 2, 1, 0
      ]
      guides = run([2, 3], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

  describe "multiple cursors 2", ->
    beforeEach ->
      rowIndents = [
        3,
        2, 3, 2, 1, 0
      ]
      guides = run([3, 4], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([0, 1])

  describe "multiple cursors on the same level", ->
    beforeEach ->
      rowIndents = [
        3,
        2, 3, 2, 1, 0
      ]
      guides = run([1, 3], 1, getRowIndents, getLastRow())

    its -> expect(guides.stack).toEqual([0, 1])
    its -> expect(guides.active).toEqual([1])

describe "getGuides", ->
  run = getGuides
  guides = null
  rowIndents = null
  getRowIndents = (r) ->
    rowIndents[r]
  getLastRow = () ->
    rowIndents.length - 1

  describe "typical", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2,
        2, 3, 0, 1, 2, 0, 1,
        1, 0
      ]
      guides = run(3, 9, getLastRow(), [2, 6, 10], getRowIndents)

    its -> expect(guides.length).toBe(6)

    its -> expect(guides[0].length).toBe(2)
    its -> expect(guides[0].point).toEqual(new Point(0, 0))
    its -> expect(guides[0].active).toBe(false)
    its -> expect(guides[0].stack).toBe(true)

    its -> expect(guides[1].length).toBe(2)
    its -> expect(guides[1].point).toEqual(new Point(0, 1))
    its -> expect(guides[1].active).toBe(true)
    its -> expect(guides[1].stack).toBe(true)

    its -> expect(guides[2].length).toBe(1)
    its -> expect(guides[2].point).toEqual(new Point(1, 2))
    its -> expect(guides[2].active).toBe(false)
    its -> expect(guides[2].stack).toBe(false)

    its -> expect(guides[3].length).toBe(2)
    its -> expect(guides[3].point).toEqual(new Point(3, 0))
    its -> expect(guides[3].active).toBe(true)
    its -> expect(guides[3].stack).toBe(true)

    its -> expect(guides[4].length).toBe(1)
    its -> expect(guides[4].point).toEqual(new Point(4, 1))
    its -> expect(guides[4].active).toBe(false)
    its -> expect(guides[4].stack).toBe(false)

    its -> expect(guides[5].length).toBe(1)
    its -> expect(guides[5].point).toEqual(new Point(6, 0))
    its -> expect(guides[5].active).toBe(true)
    its -> expect(guides[5].stack).toBe(true)

  describe "when last line is null", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2,
        2, 2, null,
        2, 0
      ]
      guides = run(3, 5, getLastRow(), [6], getRowIndents)

    its -> expect(guides.length).toBe(2)

    # `length` includes off-screen indents, which are extended by
    # counting null lines.
    its -> expect(guides[0].length).toBe(4)
    its -> expect(guides[0].point).toEqual(new Point(0, 0))
    its -> expect(guides[0].active).toBe(false)
    its -> expect(guides[0].stack).toBe(true)

    its -> expect(guides[1].length).toBe(4)
    its -> expect(guides[1].point).toEqual(new Point(0, 1))
    its -> expect(guides[1].active).toBe(true)
    its -> expect(guides[1].stack).toBe(true)

  describe "when last line is null and the following line is also null", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2,
        2, 2, null,
        null, 2, 0
      ]
      guides = run(3, 5, getLastRow(), [7], getRowIndents)

    its -> expect(guides.length).toBe(2)

    its -> expect(guides[0].length).toBe(5)
    its -> expect(guides[0].point).toEqual(new Point(0, 0))
    its -> expect(guides[0].active).toBe(false)
    its -> expect(guides[0].stack).toBe(true)

    its -> expect(guides[1].length).toBe(5)
    its -> expect(guides[1].point).toEqual(new Point(0, 1))
    its -> expect(guides[1].active).toBe(true)
    its -> expect(guides[1].stack).toBe(true)

  describe "when last line is null and the cursor doesnt follow", ->
    beforeEach ->
      rowIndents = [
        0, 1, 2,
        2, 2, null,
        null, 2, 1, 0
      ]
      guides = run(3, 5, getLastRow(), [8], getRowIndents)

    its -> expect(guides.length).toBe(2)

    its -> expect(guides[0].length).toBe(5)
    its -> expect(guides[0].point).toEqual(new Point(0, 0))
    its -> expect(guides[0].active).toBe(true)
    its -> expect(guides[0].stack).toBe(true)

    its -> expect(guides[1].length).toBe(5)
    its -> expect(guides[1].point).toEqual(new Point(0, 1))
    its -> expect(guides[1].active).toBe(false)
    its -> expect(guides[1].stack).toBe(false)
