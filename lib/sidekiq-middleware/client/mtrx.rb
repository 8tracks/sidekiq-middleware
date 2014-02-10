module Sidekiq
  module Middleware
    module Client
      class Mtrx

        def call(worker_class, item, queue)
          # See the Sidekiq::Middleware::Server::Mtrx for use of queued_at.
          #
          # We only add queued_at when the job is queued right away; for jobs
          # queued in the future, the queued_at attribute is set when the
          # Sidekiq::Poller adds the job into the main queues.
          if !item['at']
            item[:queued_at] = Time.now.to_i
          end

          yield
        end

      end
    end
  end
end
