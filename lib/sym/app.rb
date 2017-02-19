require 'sym'
require 'active_support/inflector'

module Sym

  # The {Sym::App} Module is responsible for handing user input and executing commands.
  # Central class in this module is the {Sym::App::CLI} class. However, it is
  # recommended that ruby integration with the {Sym::App} module functionality
  # is done via the {Sym::Application} class.
  #
  # Methods in this module are responsible for reporting errors and
  # maintaining the future exit code class-global variable.
  #
  # It also contains several helpers that enable some additional functionality
  # on Mac OS-X (such as using KeyChain for storing encryption keys).
  #
  module App
    class << self
      attr_accessor :exit_code
    end

    self.exit_code = 0

    def self.out
      STDERR
    end

    def self.error(
      config: {},
        exception: nil,
        type: nil,
        details: nil,
        reason: nil,
        comments: nil,
        command: nil)

      lines = []

      error_type    = "#{(type || exception.class.name).titleize}"
      error_details = (details || exception.message).split(/\s/).map(&:capitalize).join(' ')

      if exception && (config && config[:trace])
        lines << "#{error_type.red.underlined}: #{error_details.white.on.red}\n"
        lines << exception.backtrace.join("\n").red.bold if config[:trace]
        lines << "\n"
      end

      operation = command ? command.class.short_name.to_s.humanize.downcase : ''
      reason = exception.message if reason.nil? && exception
      lines << "Oops, failed to #{operation.bold}: " + " #{reason} ".bold.white.on.red if reason
      lines << "#{comments}" if comments

      self.out.puts(lines.compact.join("\n"))

      self.exit_code = 1
    end

    def self.is_osx?
      Gem::Platform.local.os.eql?('darwin')
    end

    def self.this_os
      Gem::Platform.local.os
    end
  end
end

require 'sym/version'
require 'sym/app/short_name'

require 'sym/app/args'
require 'sym/app/cli'
require 'sym/app/commands'
require 'sym/app/keychain'
require 'sym/app/output'
