require 'aruba/rspec'
require 'aruba/in_process'
require 'sym/app/cli'

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class = Sym::App::CLI
end
