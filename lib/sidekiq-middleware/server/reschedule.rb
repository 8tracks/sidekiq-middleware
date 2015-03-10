require "digest"
require "sidekiq-middleware/ext/job_lookup"

module Sidekiq
  module Middleware
    module Server
      class Reschedule
        def call(worker_instance, item, queue)

          prefix   = worker_instance.class.get_sidekiq_options['prefix']
          job_name = worker_instance.class.to_s.underscore

          STATSD.counter("#{prefix}job.#{job_name}.reschedule.before")
          yield

          if worker_instance.class.get_sidekiq_options['reschedule']
            # Ensure job hash key is removed. Even though we set a TTL on this
            # key on the client side, this ensures it's removed if something
            # goes wrong.
            payload_hash = Sidekiq.hash_for_job(item)
            Sidekiq.redis do |conn|
              conn.del(payload_hash)
            end
          end

          STATSD.counter("#{prefix}job.#{job_name}.reschedule.after")

        rescue => e
          STATSD.counter("#{prefix}job.#{job_name}.reschedule.rescue")
          raise e
        end # call
      end # Reschedule
    end # Client
  end # Middleware
end # Sidekiq

