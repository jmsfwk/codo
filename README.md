# Codo

Generate CoffeeScript documentation following the [Codo](https://github.com/coffeedoc/codo) style.

A fork of [Coffeedoc](https://github.com/maschs/coffeedocs) by Maximilian Schüßler.

![codo-generator](/docs/example.gif)

## Features

* Generate CoffeeScript documentation.
* Comment indentation for a clean look.
* `Returns` statement is configurable via template.

## How to use

Place your active cursor on the line with the function definition. Press the assigned key (default <kbd>ctrl-alt-d</kbd>) or activate `Codo: Generate` from the command palette.

## Returns template

You can set a custom template to use if `Add Returns` is enabled.

`@return %type% %desc%` (Default template)

What does this mean?
* `%desc%` will be replaced by the `[description]` block.
* `%type%` will be replaced by your default type: `type`.
* `%TYPE%` will be replaced by your default type in braces: `{type}`.
