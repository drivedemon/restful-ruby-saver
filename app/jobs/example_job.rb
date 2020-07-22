class ExampleJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records
  # are no longer available
  discard_on ActiveJob::DeserializationError

  queue_as :default

  def perform
    Rails.logger.debug("Example job performed")
  end
end
