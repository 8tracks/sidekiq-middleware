module Sidekiq
  module Middleware
    module Client
      class DigestibleJobs
        
        def call(worker_class, item, queue)
          if !worker_class.get_sidekiq_options['digestible']
            yield
            return  
          end

          Sidekiq.redis do |conn|
            # adds args to a Set
            conn.sadd("#{item['class']}:pending_args", item['args'])
          end


          # if enabled == :all && item.has_key?('at')
          #   expiration = worker_class.get_sidekiq_options['expiration'] || (item['at'].to_i - Time.new.to_i)
          #   payload = item.clone
          #   payload.delete('at')
          #   payload.delete('jid')
          # else
          #   expiration = worker_class.get_sidekiq_options['expiration'] || HASH_KEY_EXPIRATION
          #   payload = item.clone
          #   payload.delete('jid')
          # end
          # payload_hash = Digest::MD5.hexdigest(Sidekiq.dump_json(Hash[payload.sort]))

          # Sidekiq.redis do |conn|
          #   conn.watch(payload_hash)

          #   if conn.get(payload_hash)
          #     conn.unwatch
          #   else
          #     unique = conn.multi do
          #       conn.setex(payload_hash, expiration, 1)
          #     end
          #   end
          # end
        end

      end
    end
  end
end
