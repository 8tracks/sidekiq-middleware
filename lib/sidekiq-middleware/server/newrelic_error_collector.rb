module Sidekiq
  module Middleware
    module Server
      class NewrelicErrorCollector

        def call(*args)
          begin
            yield
          rescue Exception => e
            debugger
            NewRelic::Agent.notice_error(e)
            raise e
          end
        end

      end
    end
  end
end