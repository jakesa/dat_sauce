require 'cucumber'
require 'tempfile'
require 'json'
module DATSauce
  module Cucumber
    module Runner
      class << self

        # TODO - need to add logic for detecting errors?
        def run_test(test, options, run_id = nil)
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

          temp_file = Tempfile.new('test_run')

          outputs = _options.scan(/-f \S+/)
          #TODO: need to change the output from pretty to json.
          if outputs.empty?
            io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f pretty -f rerun --out #{temp_file.path}")
          else
            io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f rerun --out #{temp_file.path}")
          end

          until io.eof? do
            result = io.gets

            _results += result
          end
          Process.wait2(io.pid)
          result_hash = {}
          result_hash[:failed_tests] = process_temp_file(temp_file)
          #_results should be a JSON string
          result_hash[:results] = _results
          result_hash
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