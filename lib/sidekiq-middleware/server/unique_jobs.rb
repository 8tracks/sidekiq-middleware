require "digest"

module Sidekiq
  module Middleware
    module Server
      class UniqueJobs

        def call(worker_instance, item, queue)
          forever = worker_instance.class.get_sidekiq_options['forever']

          # Delete lock first if forever is set
          # Used for jobs which may scheduling self in future
          clear(worker_instance, item, queue) if forever

          prefix   = args[0].class.get_sidekiq_options['prefix']
          job_name = args[0].class.to_s.underscore
          begin
            yield
          rescue e
            raise e
          ensure
            clear(worker_instance, item, queue) unless forever
          end
        end

        def clear(worker_instance, item, queue)
          enabled = worker_instance.class.get_sidekiq_options['unique']

          # Enabled unique scheduled
          if enabled == :all && item.has_key?('at')
            payload = item.clone
            payload.delete('at')
            payload.delete('jid')
          else
            payload = item.clone
            payload.delete('jid')
          end
          payload_hash = Digest::MD5.hexdigest(Sidekiq.dump_json(Hash[payload.sort]))

          Sidekiq.redis { |conn| conn.del(payload_hash) }
        end

      end
    end
  end
end
