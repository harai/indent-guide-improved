{toGuides} = require '../lib/guides'
{Point} = require 'atom'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
its = (f) ->
  it f.toString(), f

describe "toGuides", ->
  guides = null
  describe "step-by-step indent", ->
    beforeEach ->
      guides = toGuides([0, 1, 2, 2, 1, 2, 1, 0])

    its -> expect(guides.length).toBe(3)
    its -> expect(guides[0].length).toBe(6)
    its -> expect(guides[0].point).toEqual(new Point(1, 0))
    its -> expect(guides[1].length).toBe(2)
    its -> expect(guides[1].point).toEqual(new Point(2, 1))
    its -> expect(guides[2].length).toBe(1)
    its -> expect(guides[2].point).toEqual(new Point(5, 1))

  describe "steep indent", ->
    beforeEach ->
      guides = toGuides([0, 3, 2, 1, 0])

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
      guides = toGuides([0, 1, 2, 3, 0])

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
      guides = toGuides([0, 1, 1, 0, 1, 0])

    its -> expect(guides.length).toBe(2)
    its -> expect(guides[0].length).toBe(2)
    its -> expect(guides[0].point).toEqual(new Point(1, 0))
    its -> expect(guides[1].length).toBe(1)
    its -> expect(guides[1].point).toEqual(new Point(4, 0))

  describe "no indent", ->
    guides = null
    beforeEach ->
      guides = toGuides([0, 0, 0])

    its -> expect(guides.length).toBe(0)

  describe "same indent", ->
    guides = null
    beforeEach ->
      guides = toGuides([1, 1, 1])

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
      guides = toGuides([1, 1.5, 1])

    its -> expect(guides.length).toBe(1)
    its -> expect(guides[0].length).toBe(3)
    its -> expect(guides[0].point).toEqual(new Point(0, 0))
