require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class Encrypt < BaseCommand
        include Sym

        required_options [ :private_key, :keyfile, :keychain, :interactive ],
                         [ :encrypt ],
                         [ :file, :string ]

        try_after :generate_key, :encrypt, :show_version, :show_help

        def execute
          send(application.action, content, application.key)
        end
      end
    end
  end
end