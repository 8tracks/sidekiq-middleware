module Sidekiq
  module Middleware
    module Server
      class Mtrx

        def call(*args)
          Sidekiq::Logging.with_context("#{args[0].class.to_s} MSG-#{args[0].object_id.to_s(36)}") do
            job_name = args[0].class.to_s.underscore
            queue_name = args[1]['queue']
            delay_ms = elapsed_ms(Time.at(args[1]['queued_at']))
            prefix = args[0].class.get_sidekiq_options['prefix']

            begin
              STATSD.timer("#{prefix}job.delay.#{job_name}", delay_ms)
              STATSD.timer("#{prefix}queue.delay.#{queue_name}", delay_ms)
              start = Time.now
              yield
              STATSD.counter("#{prefix}job.#{job_name}.success")
            rescue Exception
              STATSD.counter("#{prefix}job.#{job_name}.error")
              raise
            ensure
              STATSD.timer("#{prefix}job.#{job_name}", elapsed_ms(start))
            end
          end
        end

        def elapsed_ms(start)
          (Time.now.utc - start.utc).to_f.round(6) * 1000
        end
      end
    end
  end
end
