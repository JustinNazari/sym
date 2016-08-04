require 'secrets/cipher/base64'

module Secrets
  module Cipher
    module Base64
      class EncryptedData

        class UsageError < ArgumentError
          def initialize *args
            super('Invalid arguments – expected either encrypted or decrypted with a secret')
          end
        end

        include Secrets::Cipher::Base64

        attr_accessor :encrypted, :decrypted, :secret

        def initialize(encrypted: nil, decrypted: nil, secret: nil)
          self.secret = secret
          self.secret ||= self.class.create_secret

          if encrypted
            self.encrypted = encrypted
            self.decrypted = decr(encrypted, self.secret)
          elsif decrypted
            self.decrypted = decrypted
            self.encrypted = encr(decrypted, self.secret)
          else
            raise UsageError.new
          end
        end
      end
    end
  end
end
