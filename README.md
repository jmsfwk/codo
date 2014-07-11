# CoffeeDocs

[![Build Status](https://travis-ci.org/maschs/coffeedocs.svg?branch=master)](https://travis-ci.org/maschs/coffeedocs)

Generate CoffeeScript documentation following the [Atom documentation styleguide](https://github.com/atom/atom/blob/master/CONTRIBUTING.md#documentation-styleguide)!

![coffeedocs-generator](https://raw.github.com/maschs/coffeedocs/master/docs/example.gif)

## Features

* Generate CoffeeScript documentation.
* Comment indentation for a clean look.
* `Returns` statement is configurable via template.

## How to use

Place your active cursor on the line with the function definition. Press the assigned key or activate `Coffeedocs: Generate` from the command palette.

## Returns template

You can set a custom template to use if `Add Returns` is enabled.

`Returns the %desc% as %type%.` (Default template)

What does this mean?
* `%desc%` will be replaced by the `[description]` block.
* `%type%` will be replaced by your default type: `type`.
* `%TYPE%` will be replaced by your default type in braces: `{type}`.

### Default Keybindings
- :apple: `cmd-alt-d`
- :checkered_flag: `ctrl-alt-d`
- :penguin: `ctrl-alt-shift-d`

## Contributions

Contributors are welcome! Take a look at the [Atom contributing guide](https://github.com/atom/atom/blob/master/CONTRIBUTING.md).
