require 'json'
require 'pry'
module DATSauce
  module ResultsParser
    module Cucumber
      module TestRun
      # Take a collection of TestResult objects and aggregate their results
      # @param results_array Array<DATPages::TestResult> an array of TestResult objects
      # @return Hash the aggregated results as a Hash
        def self.parse_results(results_array)
          results_log = []
          scenarios =[]
          pass_count = 0
          fail_count = 0
          undefined_count = 0
          pending_count = 0
          failed_scenarios = []
          run_time = 0
          results_array.each do |results|
            results_summary = results.resultsSummary
            results_log << results_summary[:log]
            scenarios << results_summary
            results_log.flatten!
            case results_summary[:status]
              when 'passed'
                pass_count += 1
              when 'failed'
                fail_count += 1
                failed_scenarios << results_summary[:scenarioPath]
              when 'undefined'
                undefined_count += 1
              when 'pending'
                pending_count += 1
            end
            run_time += results_summary[:runTime]
          end

          {
              resultsLog: results_log,
              scenarios: scenarios,
              passCount: pass_count,
              failCount: fail_count,
              undefinedCount: undefined_count,
              pendingCount: pending_count,
              failedScenarios: failed_scenarios,
              runTime: run_time # this is the run time based on the cucumber results if the tests re
          }
        end
      end
    end
  end
end
