module Sidekiq
  module Middleware
    module Server
      class TerminateExceptions
        def call(*args)
          yield
        rescue Exception
          # Do nothing -- our midleware stack handles errors already
        end
      end
    end
  end
end

