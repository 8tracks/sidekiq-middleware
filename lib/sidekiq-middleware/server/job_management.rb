module Sidekiq
  module Middleware
    module Server
      class JobManagement

        def call(*args)
          instance = args[0]

          prefix = instance.class.get_sidekiq_options['prefix']
          job_name = instance.class.to_s.underscore

          skip   = false
          delay  = nil
          Sidekiq.redis do |r|
            skip = r.sismember("trax:jobs:skip", instance.class.to_s)
            delay = r.hget("trax:jobs:#{instance.class}:delay", "perform_in")
          end

          if skip
            STATSD.counter("#{prefix}job.#{instance.class.to_s.underscore}.skip")
            return

          elsif delay
            STATSD.counter("#{prefix}job.#{instance.class.to_s.underscore}.delay")
            instance.class.perform_in(delay.to_i, *args[1]["args"])
            return

          else
            STATSD.counter("#{prefix}job.#{job_name}.job_management.before")
            yield
            STATSD.counter("#{prefix}job.#{job_name}.job_management.after")

          end
        rescue => e
          STATSD.counter("#{prefix}job.#{job_name}.job_management.rescue")
          raise e
        end

      end
    end
  end
end

