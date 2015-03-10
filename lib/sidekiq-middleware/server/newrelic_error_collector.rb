module Sidekiq
  module Middleware
    module Server
      class NewrelicErrorCollector

        def call(*args)
          begin
            prefix   = args[0].class.get_sidekiq_options['prefix']
            job_name = args[0].class.to_s.underscore
            STATSD.counter("#{prefix}job.#{job_name}.newrelic_error_collector.before")
            yield
            STATSD.counter("#{prefix}job.#{job_name}.newrelic_error_collector.after")
          rescue ::RateLimiters::RateLimitReached => e
            STATSD.counter("#{prefix}job.#{job_name}.newrelic_error_collector.rescue_rate_limiter")
            # NOTE: This is an 8tracks.com specific error.
            #
            # We don't notify RPM with these errors but we still want
            # to raise so that the job is retried
            raise e

          rescue StandardError => e
            STATSD.counter("#{prefix}job.#{job_name}.newrelic_error_collector.rescue")
            options = {
              :request => nil,
              :uri => nil,
              :referer => nil,
              :metric => "Sidekiq/#{args.first.class.to_s}",
              :request_params => args[1]['args'],
              :custom_params => nil
            }

            NewRelic::Agent.notice_error(e, options)
            raise e
          end
        end

      end
    end
  end
end
