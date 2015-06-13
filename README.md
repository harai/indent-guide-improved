# indent-guide-improved package

This Atom Editor package draws indent guide more correctly and understandably.

# Features

* Active guide and stack guides are emphasized.
* Guides break just before the trailing blank lines.

![screenshot](https://raw.githubusercontent.com/harai/indent-guide-improved/master/doc/demo.gif)

# Configuration

You can change the color of guides by adding styles to [your stylesheet](https://atom.io/docs/latest/customizing-atom), such as the following:

```sass
.indent-guide-improved {
  background-color: gray;
  &.indent-guide-stack {
    background-color: cyan;
    &.indent-guide-active {
      background-color: blue;
    }
  }
}
```

# Notice

* Original "Show Indent Guide" feature is automatically switched off when this package is activated.
* Please check "Use Shadow DOM" in Settings.
