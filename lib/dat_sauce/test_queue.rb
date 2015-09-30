
module DATSauce
  class TestQueue

    def initialize(run_id, tests, test_options, queue_size)
      @run_id = run_id
      @tests = tests
      @test_options = test_options
      @queue_size = queue_size
    end

    def create_test_objects(tests)
      test_objects = []
      tests.each do |test|
        test_objects << DATSauce::Test.new(@run_id, test, @test_options)
      end
      test_objects
    end



  end


end