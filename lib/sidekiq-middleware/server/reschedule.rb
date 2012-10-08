require "digest"
require "sidekiq-middleware/ext/job_lookup"

module Sidekiq
  module Middleware
    module Server
      class Reschedule
        def call(worker_class, item, queue)
          yield

          # Ensure job hash key is removed. Even though we set a TTL on this
          # key on the client side, this ensures it's removed if something
          # goes wrong.
          payload_hash = Sidekiq.hash_for_job(item)
          Sidekiq.redis do |conn|
            conn.del(payload_hash)
          end
        end # call
      end # Reschedule
    end # Client
  end # Middleware
end # Sidekiq

