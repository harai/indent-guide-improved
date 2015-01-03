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
