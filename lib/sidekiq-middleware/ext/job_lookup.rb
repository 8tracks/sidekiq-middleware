require 'sidekiq'
require 'sidekiq/worker'

module Sidekiq
  def self.hash_for_job(job)
    payload = {"class" => job["class"], "args" => job["args"]}
    Digest::MD5.hexdigest(Sidekiq.dump_json(Hash[payload.sort]))
  end
end

module Sidekiq
  module Worker
    module ClassMethods
      def find_job(*args)
        payload_hash = Sidekiq.hash_for_job({"class" => self.to_s, "args" => args})

        json_str = nil
        Sidekiq.redis { |conn| json_str = conn.get(payload_hash) }

        return nil if json_str.nil?
        Sidekiq.load_json(json_str)
      end
    end
  end
end

