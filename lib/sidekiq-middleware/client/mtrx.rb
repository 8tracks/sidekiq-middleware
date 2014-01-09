module Sidekiq
  module Middleware
    module Client
      class Mtrx

        def call(worker_class, item, queue)
          # item[:queued_at] = Time.now.utc.to_i
          item[:queued_at] = item['at'] ? item['at'].to_i : Time.now.to_i
          yield 
        end

      end
    end
  end
end
