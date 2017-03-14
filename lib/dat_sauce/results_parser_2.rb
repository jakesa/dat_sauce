require 'json'
require 'pry'
module DATSauce
  module ResultsParser
    module Cucumber
      def self.summarize_json_results(json_results)
        scenario_list = []
        failed_scenarios = []
        pass_count = 0
        fail_count = 0
        undefined_count = 0
        pending_count = 0
        run_time = 0
        json_results.each do |feature|
          feature_path = feature['uri']
          feature['elements'].each do |scenario|
            next if scenario['type'] == 'background'
            scenario_path = "#{feature_path}:#{scenario['line']}"
            scenario_list << scenario_path
            result = check_status(scenario)
            run_time += get_run_time(scenario)
            case result
              when 'passed'
                pass_count += 1
              when 'failed'
                fail_count += 1
                failed_scenarios << scenario_path
              when 'undefined'
                undefined_count += 1
              when 'pending'
                pending_count += 1
            end
          end
        end
        {
            json_results: json_results,
            scenario_list: scenario_list,
            pass_count: pass_count,
            fail_count: fail_count,
            undefined_count: undefined_count,
            pending_count: pending_count,
            failed_scenarios: failed_scenarios,
            run_time: run_time
        }

      end

      # Take a collection of TestResult objects and aggregate their results
      # @param results_array Array<DATPages::TestResult> an array of TestResult objects
      # @return Hash the aggregated results as a Hash
      def self.aggregate_results(results_array)
        json_results = []
        scenario_list =[]
        pass_count = 0
        fail_count = 0
        undefined_count = 0
        pending_count = 0
        failed_scenarios = []
        run_time = 0
        results_array.each do |results|
          results_summary = results.results_summary
          json_results << results_summary[:json_results]
          json_results.flatten!
          scenario_list << results_summary[:scenario_list]
          scenario_list.flatten!
          pass_count += results_summary[:pass_count]
          fail_count += results_summary[:fail_count]
          undefined_count += results_summary[:undefined_count]
          pending_count += results_summary[:pending_count]
          failed_scenarios << results_summary[:failed_scenarios]
          failed_scenarios.flatten!
          run_time += results_summary[:run_time]
        end

        {
            json_results: json_results,
            scenario_list: scenario_list,
            pass_count: pass_count,
            fail_count: fail_count,
            undefined_count: undefined_count,
            pending_count: pending_count,
            failed_scenarios: failed_scenarios,
            run_time: run_time # this is the run time based on the cucumber results if the tests were un in serial. I include this but its not the actual run time
        }
      end

      private

      #TODO: there might be a bug here if the status is skipped or pending
      # cucumber statuses 'passed', 'failed', 'undefined', 'skipped', 'pending'
      # This is checking the status of the scenario based on the status of the steps
      def self.check_status(scenario)
        status = 'passed'
        scenario['steps'].each do |step|
          case step['result']['status']
            when 'failed'
              return 'failed'
            when 'undefined'
              return 'undefined'
            when 'pending'
              return 'pending'
          end
        end
        status
      end

      # go through each step and tally up their durations. The duration is in nanoseconds
      def self.get_run_time(scenario)
        time = 0
        scenario['steps'].each do |step|
          time += step['result']['duration'] unless step['result']['duration'].nil?
        end
        time
      end

    end


  end
end


  # each object in the array is a feature with a list of scenarios.
# iterate over the scenarios and look for any steps that failed. That will indicate a test failure
# if there are no failed steps, the test passed.
# Will also need to look for skipped or pending steps
# end