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

          # if there were no specified output formatters, run the tests in json format and record the results
          if outputs.empty?
            io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f json")
            until io.eof? do
              result = io.gets

              _results += result
            end
            Process.wait2(io.pid)
          else
            # if there were output formatters specified, pipe those to stdout(this is done by default), send the json results to a temp file
            # and read back that file into memory(in the form of a variable).
            # This way, the user can get console output of their choosing(presumably cucumber default output) without having to implement
            # a custom event handler. I might have to make other changes in the code for this.
            io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f json --out #{temp_file.path} ")
            Process.wait2(io.pid)
            _results = process_temp_file(temp_file)
          end
          JSON.parse(_results)
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