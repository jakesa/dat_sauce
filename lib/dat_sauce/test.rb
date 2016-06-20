require_relative 'base_test'
module DATSauce
  class Test < BaseTest
    #   run_id: "The id of the run that this test object was created for"  ---- I want to use this to later link to the test run for display in the web app
    #   name: "Test name",
    #   test_options: ['test options'],
    #   run_time: some time in millisecond notation,
    #   status: "Done", "Running", "In Queue",
    #   results: "JSON string of results"

    custom_attr_accessor :run_id, :name, :test_options, :status, :results, :run_count

    def initialize(run_id, name, test_options)
      @run_id = run_id
      @run_count = 0
      @name = name
      @test_options = test_options
      @status = "In Queue"
      @results = {:primary => nil, :rerun => nil}
    end

    def run
      @run_count += 1
      @status = "Running"
      time = Time.now
      process_results(DATSauce::Cucumber::Runner.run_test(@name, @test_options, nil), time)
    end

    def process_results(results, start_time)

      if @run_count <= 1
        results = DATSauce::Result.new(results, start_time, @run_id, 'primary')
        @results[:primary] = results
        @status = results.status
      else
        results = DATSauce::Result.new(results, start_time, @run_id, 'rerun')
        @results[:rerun] = results
        @status = results.status
      end

    end

  end


end
