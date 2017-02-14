require 'slop'
require 'sym'
require 'colored2'
require 'yaml'
require 'forwardable'
require 'openssl'
require 'sym/application'
require 'sym/errors'
require 'sym/app/commands'
require 'sym/app/keychain'
require 'sym/app/private_key/handler'
require 'highline'

require_relative 'output/file'
require_relative 'output/file'
require_relative 'output/stdout'
require_relative 'cli_slop'

module Sym
  module App
    # This is the main interface class for the CLI application.
    # It is responsible for parsing user's input, providing help, examples,
    # coordination of various sub-systems (such as PrivateKey detection), etc.
    #
    # Besides holding the majority of the application state, it contains
    # two primary public methods: +#new+ and +#run+.
    #
    # The constructor is responsible for parsing the flags and determining
    # the the application is about to do. It sets up input/output, but doesn't
    # really execute any encryption or decryption. This happens in the +#run+
    # method called immediately after +#new+.
    #
    # {{Shh::App::CLI}} module effectively performs the translation of
    # the +opts+ object (of type {Slop::Result}) and interpretation of
    # users intentions. It holds on to +opts+ for the duration of the program.
    #
    # == Responsibility Delegated
    #
    # The responsibility of determining the private key from various
    # options provided is performed by the {Sym::App::PrivateKey::Handler}
    # instance. See there for more details.
    #
    # Subsequently, +#run+ method handles the finding of the appropriate
    # {Sym::App::Commands::BaseCommand} subclass to respond to user's request.
    # Command registry, sorting, command dependencies, and finding them is
    # done by the {Sym::App::Coommands} module.
    #
    # User input is handled by the {Sym::App::Input::Handler} instance, while
    # the output is provided by the procs in the {Sym::App::Output} classes.
    #
    # Finally, the Mac OS-X -specific usage of the KeyChain, is encapsulated
    # in a cross-platform way inside the {Sym::App::Keychain} module.

    class CLI
      # brings in #parse(Array[String] args)
      include CLISlop

      extend Forwardable
      def_delegators :@application, :command

      attr_accessor :opts, :application, :outputs, :output_proc

      def initialize(argv_original)
        begin
          argv      = argv_original.dup
          dict      = argv.delete('--dictionary')
          self.opts = parse(argv)
          command_dictionary if dict
        rescue StandardError => e
          error exception: e
          return
        end

        command_no_color(argv_original) if opts[:no_color]

        self.application = ::Sym::Application.new(opts)

        select_output_stream
      end


      def execute
        return Sym::App.exit_code if Sym::App.exit_code != 0

        result = application.execute
        if result.is_a?(Hash)
          self.output_proc = ::Sym::App::Args.new({}).output_class
          error(result)
        else
          self.output_proc.call(result)
        end
      end

      private

      def command_dictionary
        options = opts.parser.unused_options + opts.parser.used_options
        puts options.map(&:to_s).sort.map { |o| "-#{o[1]}" }.join(' ')
        exit 0
      end

      def error(hash)
        Sym::App.error(hash.merge(config: (opts ? opts.to_hash : {})))
      end

      def select_output_stream
        output_klass = application.args.output_class
        unless output_klass && output_klass.is_a?(Class)
          raise "Can not determine output class from arguments #{opts.to_hash}"
        end
        self.output_proc = output_klass.new(self).output_proc
      end

      def command_no_color(argv)
        Colored2.disable! # reparse options without the colors to create new help msg
        self.opts = parse(argv.dup)
      end

      def key_spec
        '<key-spec>'.bold.magenta
      end
    end
  end
end
