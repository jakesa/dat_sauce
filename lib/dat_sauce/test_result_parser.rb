require 'json'
require 'pry'
module DATSauce
  module ResultsParser
    module Cucumber
      module Test
        def self.parse_results(json_results)
          scenario_path = ''
          run_time = 0
          status = nil

          if json_results.include? 'message'
            {
                scenarioPath: json_results['test'],
                status: json_results['status'],
                errorMessage: json_results['message'],
            }
          else
            json_results.each do |feature|
              feature_path = feature['uri']
              feature['elements'].each do |scenario|
                next if scenario['type'] == 'background'
                scenario_path = "#{feature_path}:#{scenario['line']}"
                status = check_status(scenario)
                run_time += get_run_time(scenario)
              end
            end
            {
                scenarioPath: scenario_path,
                status: status[:status],
                errorMessage: status[:errorMessage],
                failedStep: status[:failedStep],
                runTime: run_time
            }
          end
        end



        private

        #TODO: there might be a bug here if the status is skipped or pending
        # cucumber statuses 'passed', 'failed', 'undefined', 'skipped', 'pending'
        # This is checking the status of the scenario based on the status of the steps
        def self.check_status(scenario)
          result = {
              status: '',
              errorMessage: '',
              failedStep: ''
          }
          scenario['steps'].each do |step|
            case step['result']['status']
              when 'failed'
                result[:status] = 'failed'
                result[:errorMessage] = step['result']['error_message']
                result[:failedStep] = step['match']['location']
                return result
              when 'undefined'
                result[:status] = 'undefined'
                return result
              when 'pending'
                result[:status] = 'pending'
                return result
            end
          end
          result[:status] = 'passed'
          result
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
end

