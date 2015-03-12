module Sidekiq
  module Middleware
    module Server
      class TerminateExceptions
        def call(*args)
          prefix   = args[0].class.get_sidekiq_options['prefix']
          job_name = args[0].class.to_s.underscore
          yield
        rescue StandardError
          # Do nothing -- our midleware stack handles errors already
        end
      end
    end
  end
end

