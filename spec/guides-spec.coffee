{toGuides} = require '../lib/guides'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.

its = (f) ->
  it f.toString(), f

describe "toGuides", ->
  its ->
    expect(toGuides(1)).toBe(5)
