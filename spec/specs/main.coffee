describe 'Install', () ->

  it 'before', () ->

    kosher.alias 'Domain', require 'a-cli-domain'

    kosher.alias 'Install'

    kosher.alias 'stream', new kosher.WriteableStream

    kosher.alias 'instance', new kosher.Domain

      consoleOutputStream: kosher.stream

      consoleErrorStream: kosher.stream

    kosher.instance.use kosher.Install

  describe 'install', () ->

    it 'should be able to install all dependencies'

    it 'should be able to install an array of dependencies'

    it 'should be able to link install dependencies'

  describe 'uninstall', () ->

    it 'should be able to uninstall all dependencies'

    it 'should be able to uninstall an array of dependencies'

  describe 'link', () ->

    it 'should be able to link package to local repository'
