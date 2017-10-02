module Resque
  module Plugins
    module Clues
      module Instrumented
        def self.included(base)
          base.class_eval do
            class << self
              prepend ClassMethods
            end
          end
        end

        module ClassMethods
          def perform(*)
            super.tap do |return_value|
              Thread.current[Clues::RETURN_VALUE_KEY] = return_value
            end
          end
        end
      end
    end
  end
end
