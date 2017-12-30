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
          status = ''
          results_array.each do |results|
            unless results.resultsSummary.nil?
              results_summary = results.resultsSummary
              results_log << results.log
              scenarios << results_summary
              case results_summary[:status]
                when 'passed'
                  pass_count += 1
                when 'failed'
                  fail_count += 1
                  failed_scenarios << results.testId
                when 'undefined'
                  undefined_count += 1
                when 'pending'
                  pending_count += 1
              end
              run_time += results_summary[:runTime]
            end
          end
          results_log.flatten! unless results_log.flatten.nil?
          failed_scenarios.flatten! unless failed_scenarios.flatten.nil?

          if fail_count > 0
            status = 'failed'
          else
            status = 'passed'
          end

          {
              status: status,
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
