require 'sym/version'
require 'sym/app/password/providers'

module Sym
  module App
    module CLISlop
      def parse(arguments)
        Slop.parse(arguments) do |o|

          o.banner = "Sym (#{Sym::VERSION}) – encrypt/decrypt data with a private key\n".bold.white
          o.separator 'Usage:'.yellow
          o.separator '   # Generate a new key, optionally password protected, and save it'.dark
          o.separator '   # in one of: keychain, file, or STDOUT (-q turns off STDOUT) '.dark
          o.separator '   sym -g '.green.bold + '[ -p/--password ] [ -x keychain | -o file | ]  [ -q ]  '.green
          o.separator ''
          o.separator '   # To specify encryption key, provide the key as a string, file path, '.dark
          o.separator '   # OS-X Keychain, or a name of an environment variable:'.dark
          o.separator '   # or use -i to type or paste private key interactively'.dark
          o.separator '   ' + key_spec + ' = -k/--key [ key | file | keychain | env ]'.green.bold
          o.separator '                -i/--interactive'.green.bold

          o.separator ''
          o.separator '   # Encrypt/Decrypt from STDIN/file/args, to STDOUT/file:'.dark
          o.separator '   sym -e/--encrypt '.green.bold + key_spec + ' [-f [file | - ] | -s string ] [-o file] '.green
          o.separator '   sym -d/--decrypt '.green.bold + key_spec + ' [-f [file | - ] | -s string ] [-o file] '.green
          o.separator ' '
          o.separator '   # Edit an encrypted file in $EDITOR '.dark
          o.separator '   sym -t/--edit    '.green.bold + key_spec + ' -f file [ -b/--backup ]'.green.bold

          o.separator ' '
          o.separator '   # Specify any  common flags in the BASH variable. Here we'.dark
          o.separator '   # specify KeyChain name "staging" and turn on password caching'.dark
          o.separator '   export SYM_ARGS="'.green + '-ck staging'.bold.green + '"'.green
          o.separator ' '
          o.separator '   # And now encrypt using default key location '.dark + Sym.default_key_file.magenta.bold
          o.separator '   sym -e '.green.bold '-f file'.green.bold
          o.separator '   # May need to disable SYM_ARGS with -M, eg for help:'.dark
          o.separator '   sym -h -M '.green.bold

          o.separator ' '
          o.separator 'Modes:'.yellow
          o.bool      '-e', '--encrypt',            '           encrypt mode'
          o.bool      '-d', '--decrypt',            '           decrypt mode'
          o.bool      '-t', '--edit',               '           edit encrypted file in an $EDITOR'

          o.separator ' '
          o.separator 'Create a new private key:'.yellow
          o.bool      '-g', '--generate',           '           generate a new private key'
          o.bool      '-p', '--password',           '           encrypt the key with a password'
          if Sym::App.is_osx?
            o.string '-x', '--keychain',            '[key-name] '.blue + 'write the key to OS-X Keychain'
          end

          o.separator ' '
          o.separator 'Read existing private key from:'.yellow
          o.string    '-k', '--key',                '[key-spec]'.blue + ' private key, key file, or keychain'
          o.bool      '-i', '--interactive',        '           Paste or type the key interactively'

          o.separator ' '
          o.separator 'Password Cache:'.yellow
          o.bool      '-c', '--cache-passwords',     '           enable password cache'
          o.integer   '-u', '--cache-timeout',       '[seconds]'.blue + '  expire passwords after'
          o.string    '-r', '--cache-provider',      '[provider]'.blue + ' cache provider, one of ' + "#{Sym::App::Password::Providers.provider_list}"

          o.separator ' '
          o.separator 'Data to Encrypt/Decrypt:'.yellow
          o.string    '-s', '--string',             '[string]'.blue + '   specify a string to encrypt/decrypt'
          o.string    '-f', '--file',               '[file]  '.blue + '   filename to read from'
          o.string    '-o', '--output',             '[file]  '.blue + '   filename to write to'

          o.separator ' '
          o.separator 'Flags:'.yellow
          o.bool      '-b', '--backup',             '           create a backup file in the edit mode'
          o.bool      '-v', '--verbose',            '           show additional information'
          o.bool      '-q', '--quiet',              '           do not print to STDOUT'
          o.bool      '-T', '--trace',              '           print a backtrace of any errors'
          o.bool      '-D', '--debug',              '           print debugging information'
          o.bool      '-V', '--version',            '           print library version'
          o.bool      '-N', '--no-color',           '           disable color output'
          o.bool      '-M', '--no-environment',     '           disable reading flags from SYM_ARGS'

          o.separator ' '
          o.separator 'Utility:'.yellow
          o.string    '-a', '--bash-completion',    '[file]'.blue + '     append shell completion to a file'

          o.separator ' '
          o.separator 'Help & Examples:'.yellow
          o.bool      '-E', '--examples',           '           show several examples'
          o.bool      '-h', '--help',               '           show help'
        end
      end
    end
  end
end
