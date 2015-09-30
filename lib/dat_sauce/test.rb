require_relative 'base_test'
require 'ostruct'
module DATSauce
  class Test < BaseTest
    #   run_id: "The id of the run that this test object was created for"  ---- I want to use this to later link to the test run for display in the web app
    #   name: "Test name",
    #   test_options: ['test options'],
    #   run_time: some time in millisecond notation,
    #   status: "Done", "Running", "In Queue",
    #   results: "JSON string of results"

    custom_attr_accessor :run_id, :name, :test_options, :status, :results, :run_count

    # pass the test the instance of the progress bar and update it when its completed?
    # this may cause some resource conflicts since the tests will be threaded.
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
      process_results(DATSauce::Cucumber::Runner.run_test(@name, @test_options), time)
    end

    def process_results(results, start_time)

      run_time = start_time - Time.now
      if count <= 1
        @results[:primary] = {
            :results =>results,
            :results_summary => DATSauce::Cucumber::ResultsParser.summarize_results(results[:results]),
            :pass_count => DATSauce::Cucumber::ResultsParser.scenario_counts[:pass],
            :fail_count => DATSauce::Cucumber::ResultsParser.scenario_counts[:fail],
            :failed_tests =>results[:failed_tests],
            :run_time => (run_time.to_i * 1000)
        }
      else
        @results[:rerun] = {
            :results =>results,
            :results_summary => DATSauce::Cucumber::ResultsParser.summarize_results(results[:results]),
            :pass_count => DATSauce::Cucumber::ResultsParser.scenario_counts[:pass],
            :fail_count => DATSauce::Cucumber::ResultsParser.scenario_counts[:fail],
            :failed_tests =>results[:failed_tests],
            :run_time => (run_time.to_i * 1000)
        }
      end

      @status = "Done"
    end

  end


end
