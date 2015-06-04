#
# Copyright (c) 2014 by Maximilian Schüßler. See LICENSE for details.
#

_ = require 'lodash'

# Public: CoffeeDocs main class.
class CoffeeDocs

  # Public: Returns the setting under the key 'key'.
  #
  # * `key` The config key as {String}.
  #
  # Returns: Returns the value of config key.
  getConfigValue: (key) ->
    switch key
      when 'addReturns'
        value = atom.config.get('coffeedocs.addReturns')
      when 'ReturnsDefaultType'
        value = atom.config.get('coffeedocs.ReturnsDefaultType')
      when 'SearchLineBelowInstead'
        value = atom.config.get('coffeedocs.SearchLineBelowInstead')
      when 'argumentsTemplate'
        value = atom.config.get('coffeedocs.argumentsTemplate')
      when 'ReturnsTemplate'
        value = atom.config.get('coffeedocs.ReturnsTemplate')
      else value ?= null
    value

  # Public: Get the active Editor.
  #
  # Returns: The active Editor.
  getEditor: -> atom.workspace.getActiveTextEditor()

  # Public: Returns the function definition from row n.
  #
  # * `editor` The Editor to read from.
  # * `n`      The row number to read from.
  #
  # Returns: The function definition as {Object}:
  #   * `name` The name of the function as {String}.
  #   * `args` The arguments of the function as {Array}.
  getFunctionDef: (editor, n) ->
    return unless @isFunctionDef(editor, n)

    regex = /\s*([a-zA-Z_$@][a-zA-Z_$0-9]*) *[:=](\(?.*\)?) *[-=]>.*/
    line = @readLine(editor, n)?.match(regex)
    functionName = line[1]
    functionArgs = []

    if /.*\((.*)\).*/.test line[2]
      line = line[2].match /.*\((.*)\).*/
      functionArgs = line[1].split(',')
      for arg, i in functionArgs
        functionArgs[i] = arg.match(/\s*@?(.*)\s*/)[1]

    return {name: functionName, args: functionArgs}

  # Public: Checks if the active line defines a function.
  #
  # * `editor` The Editor to check from.
  # * `n`      The row {Number} to check.
  #
  # Returns: {Boolean}
  isFunctionDef: (editor, n) ->
    regex = /\s*([a-zA-Z_$@][a-zA-Z_$0-9]*) *[:=](\(?.*\)?) *[-=]>.*/
    line = @readLine(editor, n)
    regex.test(line)

  # Public: Test if the line n defines a class.
  #
  # * `editor` The Editor to check from as {Object}.
  # * `n`      The row to check as {Number}.
  #
  # Returns: {Boolean}
  isClassDef: (editor, n) ->
    regex = /[ \t]*class[ \t]*([$_a-zA-z0-9]+)[ \t]*(?:extends)?[ \t]*([$_a-zA-z0-9]*)/g
    line = @readLine(editor, n)
    regex.test(line)

  # Public: Get the class definition from row n.
  #
  # * `editor` The Editor to read from as {Object}.
  # * `n`      The row to read from as {Number}.
  #
  # Returns: The class definition as {Object}:
  #   * `name`    The name of the class as {String}.
  #   * `extends` The name of the class that is being extended as {String} or
  #     `null` if there is none.
  getClassDef: (editor, n) ->
    regex = /[ \t]*class[ \t]*([$_a-zA-z0-9]+)[ \t]*(?:extends)?[ \t]*([$_a-zA-z0-9]*)/
    line = @readLine(editor, n)?.match(regex)
    {name: line?[1] or null, 'extends': if line?[2]?.length>0 then line[2] else null}

  # Public: Read the specified line.
  #
  # * `editor` The Editor to read from. If not set, use the active Editor.
  # * `n`      The row {Number} to read from.
  #
  # Returns: The line as {String}.
  readLine: (editor, n) ->
    editor = @getEditor() unless editor?
    return editor.getCursor()?.getCurrentBufferLine() unless n?
    editor.lineTextForBufferRow(n)

  # Public: Parse the active line.
  parse: ->
    editor = @getEditor()
    return unless editor?

    linePos = editor.getCursorScreenPosition().row
    linePos++ if @getConfigValue 'SearchLineBelowInstead'

    classDef = @getClassDef(editor, linePos)
    functionDef = @getFunctionDef(editor, linePos)
    return unless classDef? or functionDef?

    snippet = @generateSnippetClass(classDef) if classDef?
    snippet = @generateSnippetFunc(functionDef) if functionDef?
    @writeSnippet(editor, snippet)

  # Public: Write a snippet into active editor using the snippets package.
  #
  # * `editor` The Editor the snippet gets activated in.
  # * `str`    The {String} containing the snippet code.
  writeSnippet: (editor, str) ->
    return if not editor? or not str?
    if @getConfigValue 'SearchLineBelowInstead'
      editor?.insertNewline()
    else
      editor?.insertNewlineAbove()

    Snippets = atom.packages.activePackages.snippets.mainModule
    Snippets?.insert(str, editor)

  # Public: Generates a suitable snippet base on the functionDef.
  #
  # * `functionDef` - The {Object} with the function definition:
  #   * `name` {String} with name of the function.
  #   * `args` {Array} with function arguments.
  #
  # Returns: The generated snippet as {String}.
  generateSnippetFunc: (functionDef) ->
    functionName = functionDef.name
    functionArgs = functionDef.args

    snippet = '''
      # ${1:Public}: ${2:[Description]}
    '''
    snippetIndex = 3

    if functionArgs.length>=1
      snippet += '\n#'

      functionArgs = @indentFunctionArgs(functionArgs)
      for arg in functionArgs
        snippet += "\n# * `#{arg}` The ${#{snippetIndex}:[description]} as {${#{snippetIndex+1}:[type]}}."
        snippetIndex = snippetIndex+2

    if @getConfigValue('addReturns')
      returnType = @getConfigValue('ReturnsDefaultType')
      returnTemplate = @getConfigValue('ReturnsTemplate')
      [partial] = partialSnippetReturns(returnTemplate, returnType, snippetIndex)
      snippet += '\n#\n# ' + partial

    snippet += '$0'

  # Public: Generates a suitable snippet base for the classDef.
  #
  # * `classDef` The class definition as {Object}:
  #   * `name`    The name of the class as {String}.
  #   * `extends` The name of the class that is being extended as {String}.
  #
  # Returns: The snippet as {String}.
  generateSnippetClass: (classDef) ->
    className = classDef.name
    classExtends = classDef.extends

    if not classExtends?
      snippet = '''
        # ${1:Public}: ${2:[Description]}.
      '''
    else
      snippet = """
        # ${1:Public}: ${2:[Description]} that extends the {#{classExtends}} prototype.
      """
    snippet

  # Public: Indentates the arguments and removes default values.
  #
  # * `args` The {Array} containing the function arguments.
  #
  # Returns: The indented arguments as {Array}.
  indentFunctionArgs: (args) ->
    maxLength = 1
    for arg, i in args
      arg = args[i] = arg.split('=')[0]
      if arg.length > maxLength
        maxLength = arg.length

    for arg, i in args
      args[i] = @appendWhitespaces(arg, maxLength-arg.length)

    return args

  # Internal: Appends n whitespaces to str.
  #
  # * `str` The {String} to append to.
  # * `n`   The amount of whitespaces to append.
  #
  # Returns: str as {String} with appended whitespaces.
  appendWhitespaces: (str, n) ->
    return str if n<1
    str += ' ' for [0...n]
    return str

  # Internal: Parses the 'Returns' template and inserts the type if necessary.
  #
  # * `template`     The template as {String}.
  #                  %TYPE% will be surrounded by braces
  #                  %type% will be without any brackets.
  # * `typeReturn`   The type that is being returned as {String}.
  # * `snippetIndex` The snippetIndex as {Number}.
  #
  # Returns an {Array} with:
  #   * `0` The parsed template.
  #   * `1` The next free snippetIndex as {Number}.
  partialSnippetReturns = (template, typeReturn, snippetIndex) ->
    indexType = _.max template.indexOf('%TYPE%'), template.indexOf('%type%')
    indexDescription = template.indexOf('%desc%')
    containsType = indexType > -1
    containsDesc = indexDescription > -1

    if containsType and containsDesc
      if indexType > indexDescription
        replacementDescription = "${#{snippetIndex}:[Description]}"
        replacementBraced   = "{${#{snippetIndex+1}:#{typeReturn}}}"
        replacementUnbraced = "${#{snippetIndex+1}:#{typeReturn}}"
      else
        replacementDescription = "${#{snippetIndex+1}:[Description]}"
        replacementBraced   = "{${#{snippetIndex}:#{typeReturn}}}"
        replacementUnbraced = "${#{snippetIndex}:#{typeReturn}}"
      snippetIndex += 2
    else
      replacementDescription = "${#{snippetIndex}:[Description]}"
      replacementBraced   = "{${#{snippetIndex+1}:#{typeReturn}}}"
      replacementUnbraced = "${#{snippetIndex+1}:#{typeReturn}}"
      snippetIndex += 1 if containsType or containsDesc


    template = template.replace '%desc%', replacementDescription
    template = template.replace '%TYPE%', replacementBraced
    template = template.replace '%type%', replacementUnbraced
    [template, snippetIndex]

module.exports = CoffeeDocs
