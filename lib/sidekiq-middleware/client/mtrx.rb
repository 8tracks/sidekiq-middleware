module Sidekiq
  module Middleware
    module Client
      class Mtrx

        def call(worker_class, item, queue)
          # queued_at is the time it entered the queue, if performed in 1 hour, it will be 1 hour from now

          # item[:queued_at] = Time.now.utc.to_i
          item[:queued_at] = item['at'] ? item['at'].to_i : Time.now.to_i
          yield 
        end

      end
    end
  end
end
