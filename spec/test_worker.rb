class TestWorker
  @queue = :test_queue

  def self.perform(first, second)
    "IGNORED RETURN VALUE"
  end
end

class InstrumentedTestWorker
  include Resque::Plugins::Clues::Instrumented
  @queue = :test_queue

  def self.perform(first, second)
    "RETURN VALUE"
  end
end
