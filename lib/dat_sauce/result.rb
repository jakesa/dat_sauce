
require_relative 'custom_accessor'
module DATSauce
  class Result
    extend CustomAccessor

    custom_attr_accessor :log, :results_summary, :pass_count, :fail_count, :failed_tests, :run_time, :status, :aggregate_run_time, :run_id, :result_id

    def initialize(results, start_time, run_id, result_type)
      run_time = Time.now - start_time
      @log = results[:results].nil? ? '' : results[:results]
      @run_id = run_id
      @result_type = result_type
      @result_id = run_id + result_type
      @results_summary = results[:results].nil? ? '' : DATSauce::Cucumber::ResultsParser.summarize_results(results[:results])
      @pass_count = DATSauce::Cucumber::ResultsParser.scenario_counts[:pass]
      @fail_count = DATSauce::Cucumber::ResultsParser.scenario_counts[:fail]
      if results[:failed_tests].is_a? Array
        @failed_tests = results[:failed_tests].flatten
      else
        @failed_tests = results[:failed_tests].split
      end
      @run_time = (run_time)

      if @failed_tests.empty? && @fail_count.nil?
        @status = 'Passed'
      else
        @status = 'Failed'
      end
    end

    def to_hash
      obj = {}
      Result.attrs.each do |attr| #need to fix this. this looks at the Test class specifically and not whatever child class called it
        obj[attr] = send(attr)
      end
      obj
    end

    def to_json
      JSON.generate to_hash
    end

    def to_s(log = false)
      str = ''
      Result.attrs.each do |attr| #need to fix this. this looks at the Test class specifically and not whatever child class called it
        str << "#{attr}: #{send(attr)}\n" unless attr == :log && !log
      end
    end
  end

end