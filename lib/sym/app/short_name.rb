require 'active_support/inflector'
module Sym
  module App
    module ShortName
      def short_name
        self.name.split(/::/)[-1].underscore.to_sym
      end
    end
  end
end
