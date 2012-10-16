module Sidekiq
  module Middleware
    module Server
      class Mtrx

        def call(*args)
          Sidekiq::Logging.with_context("#{args[0].class.to_s} MSG-#{args[0].object_id.to_s(36)}") do
            begin
              start = Time.now
              STATSD.timing("queue.#{args[0].class.to_s.underscore}", elapsed_ms(Time.at(args[1]['queued_at'])))
              yield
              STATSD.increment("job.#{args[0].class.to_s.underscore}.success")
            rescue Exception
              STATSD.increment("job.#{args[0].class.to_s.underscore}.error")
              raise
            ensure
              STATSD.timing("job.#{args[0].class.to_s.underscore}", elapsed_ms(start))
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
