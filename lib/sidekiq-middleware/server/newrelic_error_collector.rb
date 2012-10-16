module Sidekiq
  module Middleware
    module Server
      class NewrelicErrorCollector

        def call(*args)
          begin
            yield
          rescue Exception => e
            options = { 
              :request => nil,
              :uri => "Sidekiq/#{args.first.class.to_s}",
              :referer => nil,
              :metric => "metric: [Sidekiq] #{args.first.class.to_s}",
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