{ resolve } = require 'path'

ACliCommand = require 'a-cli-command'

class Install extends ACliCommand

  command:

    name: "install"

    options:

      home:

        alias: "h"

        type: "string"

        default: "#{process.env.HOME}/local/lib/node_modules"

        description: [
          "the default home directory where",
          "packages should be searched for",
          "and linked to"
        ]

      bin:

        alias: "b"

        type: "string"

        default: "npm"

        description: [
          "the binary command to call",
          "defaults to npm but allows support",
          "for similar command line utilities",
          "like bower or component"
        ]

      file:

        alias: "f"

        type: "string"

        default: "package"

        description: [
          "specifies the package file that will",
          "will be required to determine dependencies",
          "and link name. should be in JSON format.",
          "this option is always enabled when",
          "linking, installing or uninstalling"
        ]

      fields:

        type: "array"

        default: ["dependencies", "devDependencies"]

        usage: "[ <field> [, <field> ... ] ]"

        description: [
          "specify wich fields should be used",
          "as dependencies fields"
        ]

      link:

        alias: "l"

        type: "string"

        triggers: [ "bin", "home", "file" ]

        description: [
          "link the current npm package to",
          "your local node_modules folder",
          "or dependencies to ./node_modules",
          "when used with install"
        ]

      install:

        alias: "i"

        type: "array"

        triggers: [ "fields", "file", "bin" ]

        usage: "[ -f|l|b|n ] [ <dependency> [, <dependency> ... ] ]"

        description: [
          "install npm package dependencies",
          "if no dependencies are listed all",
          "dependencies (*) will be installed"
        ]

      uninstall:

        alias: "u"

        type: "array"

        triggers: [ "fields", "file", "bin" ]

        usage: "[ -f ] [ <dependency> [, <dependency> ... ] ]"

        description: [
          "uninstall npm package dependencies"
        ]

  dependencies: (pkg, fields) ->

    return fields.map (field) ->

      return Object.keys(pkg[field] or {}).map (dependency) ->

        if version = pkg[field][dependency]

          return "#{dependency}@#{version}"

        return "#{dependency}"

  "file?": (command, next) ->

    @shell

    try

      file = resolve command.args.file

      pkg = require file

      command.args.file = pkg

      next null, "file: #{file}"

    catch err then next err, null

  "link?": (command, next) ->

    { bin, home, link, install, file } = command.args

    home = resolve home

    if not install

      @shell

      if link.length is 0

        { name: pkgname } = file

        dest = resolve home, pkgname

        ln "-sf", pwd(), dest

        if test "-e", dest

          @cli.console.info "#{pwd()} -> #{resolve(link)}"

          return next null, "linked"

        return next "couldnt link #{dest}", null

      else

        src = resolve home, link

        if test "-e", src

          ln "-sf", src, link

          if test "-e", link

            @cli.console.info "#{resolve(link)} -> #{file}"

            return next null, "linked"

          return next "error could not link #{file}", null

        return next "error could find #{link}", null

    return next null, "install"

  "install?": (command, next) ->

    @shell

    { install, link, fields, file, bin } = command.args

    if install.length is 0

      fields ?= [ "dependencies" ]

      install = []

      install = install.concat.apply install, @dependencies(file, fields)

    install = install.join ' '

    if typeof link is "string" then bin = "#{bin} link #{install}"

    else bin = "#{bin} install #{install}"

    @exec bin, next

  "uninstall?": (command, next) ->

    @shell

    { uninstall, link, fields, file, bin } = command.args

    if uninstall.length is 0

      fields ?= [ "dependencies" ]

      uninstall = []

      uninstall = uninstall.concat.apply uninstall, @dependencies(file, fields)

    uninstall = uninstall.join ' '

    bin = "#{bin} uninstall #{uninstall}"

    @exec bin, next

module.exports = Install
