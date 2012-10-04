require "digest"
require "sidekiq-middleware/ext/job_lookup"

module Sidekiq
  module Middleware
    module Client
      class Reschedule
        def call(worker_class, item, queue)
          # Item is scheduled to run later
          if item.has_key?("at")

            # We cannot rely on item['jid'] for the item key in redis since
            # it's randomly generated each time a job is queued. Instead, we'll
            # rely on item['class'] & item['args']. We only rely on these two
            # instead of the whole item since this allows use to add/remove
            # sidekiq options and not affect the hashing - easier to deploy new
            # features.
            payload = item.clone
            payload_hash = Sidekiq.hash_for_job(payload)

            # TODO Make this uniqe using multi/watch
            Sidekiq.redis do |conn|
              # Job has been scheduled - remove old one
              if original_job_item = conn.get(payload_hash)
                conn.zrem("schedule", original_job_item)
              end

              # Set the timestamp for this job so we can look it up again when
              # we want to reschedule the job.
              conn.setex(payload_hash, item["at"].to_i - Time.now.to_i, Sidekiq.dump_json(item))
            end
          end

          yield

        end # call
      end # Reschedule
    end # Client
  end # Middleware
end # Sidekiq
