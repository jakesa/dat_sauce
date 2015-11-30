require 'cucumber'
require 'tempfile'
require 'json'
module DATSauce
  module Cucumber
    module Runner
      class << self

        # TODO - need to add logic for detecting errors?
        def run_test(test, options, run_id = nil, progress_bar = nil, output = true, team_city = false)
          ENV["AUTOTEST"] = "1" if $stdout.tty?
          _results = ''
          _options = ''

          begin
            options.each do |option|
              _options += " #{option}"
            end

          rescue => e
            puts "there was an error"
            puts e
            puts e.backtrace
          end

          # puts "Running test: #{test}"
          # progress_bar.log("Running test: #{test}")
          # progress_bar.refresh
          temp_file = Tempfile.new('test_run')

          outputs = _options.scan(/-f \S+/)

          if outputs.empty?
            io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f pretty -f rerun --out #{temp_file.path}")
          else
            io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f rerun --out #{temp_file.path}")
          end

          until io.eof? do
            result = io.gets

            puts result if output && !team_city

            # progress_bar.log(result) if output

            _results += result
          end
          Process.wait2(io.pid)
          result_hash = {}
          result_hash[:failed_tests] = process_temp_file(temp_file)
          # progress_bar.log("Failed tests: #{result_hash[:failed_tests]}") unless result_hash[:failed_tests].nil? || result_hash[:failed_tests] == ''
          # progress_bar.log result_hash[:failed_tests]
          # progress_bar.log result_hash[:failed_tests].class
          # progress_bar.log result_hash[:failed_tests].empty?
          DATSauce::TCMessageBuilder.start_test_suite test if team_city
          DATSauce::TCMessageBuilder.start_test test if team_city
          if output && team_city
            # DATSauce::TCMessageBuilder.report_message :message => DATSauce::TCMessageBuilder.format_text(_results)
            DATSauce::TCMessageBuilder.report_stdout test, DATSauce::TCMessageBuilder.format_text(_results)
          end
          unless result_hash[:failed_tests].empty?
            # progress_bar.log _results
            DATSauce::TCMessageBuilder.test_failed(:name => test) if team_city
            progress_bar.log result_hash[:failed_tests].to_s if progress_bar
          end
          DATSauce::TCMessageBuilder.finish_test(test) if team_city
          DATSauce::TCMessageBuilder.finish_test_suite test if team_city
          result_hash[:results] = _results
          result_hash
          # JSON.generate result_hash
        end

        private

        def process_temp_file(file)
          failed_scenarios = ''
          until file.eof?
            failed_scenarios << file.gets
          end
          failed_scenarios
        end
      end

    end
  end


end