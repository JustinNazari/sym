require 'colored2'
require 'zlib'
require 'logger'

require_relative 'sym/configuration'

Sym::Configuration.configure do |config|
  config.password_cipher     = 'AES-128-CBC'
  config.data_cipher         = 'AES-256-CBC'
  config.private_key_cipher  = config.data_cipher
  config.compression_enabled = true
  config.compression_level   = Zlib::BEST_COMPRESSION

  config.password_cache_timeout          = 300

  # When nil is selected, providers are auto-detected.
  config.password_cache_default_provider = nil
  config.password_cache_arguments        = {
    drb:       {
      opts: {
        uri: 'druby://127.0.0.1:24924'
      }
    },
    memcached: {
      args: %w(127.0.0.1:11211),
      opts: { namespace:  'sym',
              compress:   true,
              expires_in: config.password_cache_timeout
      }

    }
  }
end


#
# == Using Sym Library
#
# This library is a "wrapper" that allows you to take advantage of the
# symmetric encryption functionality provided by the {OpenSSL} gem (and the
# underlying C library). In order to use the library in your ruby classes, you
# should _include_ the module {Sym}.
#
# The including class is decorated with four instance methods from the
# module {Sym::Extensions::InstanceMethods} and two class methods from
# {Sym::Extensions::ClassMethods} – for specifics, please refer there.
#
# The two main instance methods are +#encr+ and +#decr+, which as the name
# implies, perform two-way symmetric encryption and decryption of any Ruby object
# that can be +marshaled+.
#
# Two additional instance methods +#encr_password+ and +#decr_password+ turn on
# password-based encryption, which actually uses a password to construct a 128-bit
# long private key, and then uses that in the encryption of the data.
# You could use them to encrypt data with a password instead of a randomly
# generated private key.
#
# The library comes with a rich CLI interface, which is mostly encapsulated under the
# +Sym::App+ namespace.
#
# The +sym+ executable that is the "app" in this case, and is a _user_ of the
# API methods +#encr+ and +#decr+.
#
# Create a new key with +#create_private_key+ class method, which returns a new
# key every time it's called, or with +#private_key+ class method, which either
# assigns, or creates and caches the private key at a class level.
#
# == Example
#
#     require 'sym'
#
#     class TestClass
#       include Sym
#       # read the key from environmant variable and assign to this class.
#       private_key ENV['PRIVATE_KEY']
#
#       def sensitive_value=(value)
#         @sensitive_value = encr(value, self.class.private_key)
#       end
#
#       def sensitive_value
#         decr(@sensitive_value, self.class.private_key)
#       end
#     end
#
# == Private Key
#
# They private key can be generated by +TestClass.create_private_key+
# which returns but does not store a new random 256-bit key.
#
# The key can be assigned and saved, or auto-generated and saved using the
# +#private_key+ method on the class that includes the +Sym+ module.
#
# Each class including the +Sym+ module would get their own +#private_key#
# class-instance variable accessor, and a possible value.
#
# For example:
#
#

module Kernel
  def require_dir(___dir)
    @___dir ||= File.dirname(__FILE__)
    # require files using a consistent order based on the dir/file name.
    # this should be OS-neutral
    Dir["#{@___dir}/#{___dir}/*.rb"].sort.each do |___file|
      require(___file)
    end
  end
end

class Object
  unless self.methods.include?(:present?)
    def present?
      return false if self.nil?
      if self.is_a?(String)
        return false if self == ''
      end
      true
    end
  end
end

require_dir 'sym/extensions'

module Sym
  def self.included(klass)
    klass.instance_eval do
      include ::Sym::Extensions::InstanceMethods
      extend ::Sym::Extensions::ClassMethods
      class << self
        def private_key(value = nil)
          if value
            @private_key= value
          elsif @private_key
            @private_key
          else
            @private_key= self.create_private_key
          end
          @private_key
        end
      end
    end
  end

  COMPLETION_FILE        = '.sym.completion'.freeze
  COMPLETION_PATH        = "#{ENV['HOME']}/#{COMPLETION_FILE}".freeze
  NIL_LOGGER             = Logger.new(nil).freeze # empty logger
  LOGGER                 = Logger.new(STDOUT).freeze
  ENV_ARGS_VARIABLE_NAME = 'SYM_ARGS'.freeze

  BASH_COMPLETION        = {
    file:   File.expand_path('../../bin/sym.completion', __FILE__),
    script: "[[ -f '#{COMPLETION_PATH}' ]] && source '#{COMPLETION_PATH}'",
  }.freeze
end

