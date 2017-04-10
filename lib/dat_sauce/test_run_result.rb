# require_relative 'results_parser_2'
require_relative 'test_run_result_parser'
require_relative 'custom_accessor'
module DATSauce
  class TestRunResult
    extend CustomAccessor

    custom_attr_accessor :log, :resultsSummary, :passCount, :failCount, :failedScenarios, :runTime, :status,
                         :startTime, :runId, :resultId, :scenarios, :pendingCount, :undefinedCount, :duration

    def initialize(results, start_time, run_id, result_type)
      # parsed_results = DATSauce::ResultsParser::Cucumber.aggregate_results results

      # @log = parsed_results[:json_results]
      # @results_summary = parsed_results
      # @start_time = start_time
      # @run_id = run_id
      # @result_type = result_type
      # @fail_count = parsed_results[:fail_count]
      # @pass_count = parsed_results[:pass_count]
      # @pending_count = parsed_results[:pending_count]
      # @undefined_count = parsed_results[:undefined_count]
      # @run_time = Time.now - start_time # run time based on the start and stop time of the test from within the dat sauce run process and not the run time off the cucumber results
      # @scenario_list = parsed_results[:scenario_list]
      # @failed_scenarios = parsed_results[:failed_scenarios]
      # @status = parsed_results[:fail_count] > 0 ? 'Failed' : 'Passed' #there could be a bug here
      @resultsSummary = DATSauce::ResultsParser::Cucumber::TestRun.parse_results results
      @log = @resultsSummary[:results_log]
      @startTime = start_time
      @runId = run_id
      @resultType = result_type
      @failCount = @resultsSummary[:failCount]
      @passCount = @resultsSummary[:passCount]
      @pendingCount = @resultsSummary[:pendingCount]
      @undefinedCount = @resultsSummary[:undefinedCount]
      @runTime = Time.now - start_time # run time based on the start and stop time of the test from within the dat sauce run process and not the run time off the cucumber results
      @scenarios = @resultsSummary[:scenarios]
      @failedScenarios = @resultsSummary[:failedScenarios]
      @status = @resultsSummary[:status]
    end

    def to_hash
      obj = {}
      TestRunResult.attrs.each do |attr| #need to fix this. this looks at the Test class specifically and not whatever child class called it
        obj[attr] = send(attr)
      end
      obj
    end

    def to_json
      JSON.generate to_hash
    end

    def to_s(log = false)
      str = ''
      TestRunResult.attrs.each do |attr| #need to fix this. this looks at the Test class specifically and not whatever child class called it
        str << "#{attr}: #{send(attr)}\n" unless attr == :log && !log
      end
      str
    end
  end

end