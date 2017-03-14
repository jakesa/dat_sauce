require_relative 'results_parser_2'
require_relative 'custom_accessor'
module DATSauce
  class TestResult
    extend CustomAccessor

    custom_attr_accessor :log, :results_summary, :pass_count, :fail_count, :failed_scenarios, :run_time, :status,
                         :start_time, :run_id, :result_id, :scenario_list, :pending_count, :undefined_count

    def initialize(results, start_time, run_id, result_type)
      parsed_results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
      @log = parsed_results[:json_results]
      @results_summary = parsed_results
      @start_time = start_time
      @run_id = run_id
      @result_type = result_type
      @fail_count = parsed_results[:fail_count]
      @pass_count = parsed_results[:pass_count]
      @pending_count = parsed_results[:pending_count]
      @undefined_count = parsed_results[:undefined_count]
      @run_time = parsed_results[:run_time]
      @scenario_list = parsed_results[:scenario_list]
      @failed_scenarios = parsed_results[:failed_scenarios]
      @status = parsed_results[:fail_count] > 0 ? 'Failed' : 'Passed' #there could be a bug here

    end

    def to_hash
      obj = {}
      TestResult.attrs.each do |attr|
        obj[attr] = send(attr)
      end
      obj
    end

    def to_json
      JSON.generate to_hash
    end

    def to_s(log = false)
      str = ''
      TestResult.attrs.each do |attr|
        str << "#{attr}: #{send(attr)}\n" unless attr == :log && !log
      end
      str
    end
  end

end