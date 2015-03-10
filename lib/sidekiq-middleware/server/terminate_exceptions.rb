module Sidekiq
  module Middleware
    module Server
      class TerminateExceptions
        def call(*args)
          prefix   = args[0].class.get_sidekiq_options['prefix']
          job_name = args[0].class.to_s.underscore
          STATSD.counter("#{prefix}job.#{job_name}.terminate_exceptions.before")
          yield
          STATSD.counter("#{prefix}job.#{job_name}.terminate_exceptions.after")
        rescue StandardError
          STATSD.counter("#{prefix}job.#{job_name}.terminate_exceptions.rescue")
          # Do nothing -- our midleware stack handles errors already
        end
      end
    end
  end
end

