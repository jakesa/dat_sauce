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
          end

          puts "Running test: #{test}"
          temp_file = Tempfile.new('test_run')
          io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f pretty -f rerun --out #{temp_file.path}")
          until io.eof? do
            result = io.gets
            # puts result
            _results += result
          end
          Process.wait2(io.pid)
          result_hash = {}
          result_hash[:failed_tests] = process_temp_file(temp_file)
          result_hash[:results] = _results
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