{toGuides} = require '../lib/guides'
{Point} = require 'atom'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.

its = (f) ->
  it f.toString(), f

describe "toGuides", ->
  its ->
    guides = toGuides([0, 1, 2, 2, 1, 2, 1, 0])
    expect(guides.length).toBe(3)
    expect(guides[0].length).toBe(6)
    expect(guides[0].point.column).toBe(0)
    expect(guides[0].point.row).toBe(1)
