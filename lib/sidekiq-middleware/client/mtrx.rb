module Sidekiq
  module Middleware
    module Client
      class Mtrx

        def call(worker_class, item, queue)
          item[:queued_at] = Time.now.utc.to_i
          yield 
        end

      end
    end
  end
end
