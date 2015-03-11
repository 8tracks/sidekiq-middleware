module Sidekiq
  module Middleware
    module Server
      class JobManagement

        def call(*args)
          instance = args[0]

          prefix = instance.class.get_sidekiq_options['prefix']
          job_name = instance.class.to_s.underscore

          skip   = false
          delay  = nil
          Sidekiq.redis do |r|
            skip = r.sismember("trax:jobs:skip", instance.class.to_s)
            delay = r.hget("trax:jobs:#{instance.class}:delay", "perform_in")
          end

          if skip
            STATSD.counter("#{prefix}job.#{instance.class.to_s.underscore}.skip")
            return

          elsif delay
            STATSD.counter("#{prefix}job.#{instance.class.to_s.underscore}.delay")
            instance.class.perform_in(delay.to_i, *args[1]["args"])
            return

          else
            if !rate_limited(instance)
              yield
            else
              STATSD.counter("#{prefix}job.#{instance.class.to_s.underscore}.rate_limited")
              instance.class.perform_in(rand(60*60), *args[1]["args"])
              return
            end
          end
        rescue => e
          raise e
        end

        def rate_limited(instance)
          if threshold = instance.class.get_sidekiq_options['rate_limit_threshold']
            interval = instance.class.get_sidekiq_options['rate_limit_interval'] || 60

            return !within_rate_limit?(instance.class.to_s, threshold.to_i, interval.to_i)
          else
            return false
          end
        end

        def within_rate_limit?(name, threshold, interval)
          threshold = threshold
          interval = interval

          # ie: turns 25 req per 60 seconds into 5 per 12 seconds
          # if gcd = threshold.gcd(interval) and gcd > 1
          #   threshold = threshold / gcd
          #   interval =  interval / gcd
          # end

          res = nil
          Sidekiq.redis do |redis|
            # TODO: switch to CACHE server once converted to 2.6
            res = redis.eval(%Q{
              local current
              current = redis.call('INCR', KEYS[1])

              if tonumber(current) == 1 then
                redis.call("expire",KEYS[1],tonumber(ARGV[1]))
              end

              return current
            }, [ name ], [ interval ])
          end

          return res <= threshold
        end

      end
    end
  end
end

