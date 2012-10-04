require "sidekiq-middleware/version"
require "sidekiq-middleware/middleware"

Dir[File.dirname(__FILE__) + "/sidekiq-middleware/server/*.rb"].each { |file| require(file) }
Dir[File.dirname(__FILE__) + "/sidekiq-middleware/client/*.rb"].each { |file| require(file) }

require 'sidekiq-middleware/ext/job_lookup'
