require 'cucumber'
require 'tempfile'
require 'json'
module DATSauce
  module Cucumber
    module Runner
      class << self

        # TODO - need to add logic for detecting errors?
        def run_test(test, options, run_id = nil, cmd=nil)
          ENV["AUTOTEST"] = "1" if $stdout.tty?
          _results = ''
          _options = ''

          begin
            options.each do |option|
              _options += " #{option}"
            end

          rescue => e
            puts 'there was an error'
            puts e
            puts e.backtrace
          end

          temp_file = Tempfile.new('test_run')
          if cmd.nil?
            io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f json --out #{temp_file.path}")
            Process.wait2(io.pid)
            _results = process_temp_file(temp_file)
          else
            #TODO - this is setup for allowing the user to pass in a command to run. This allows someone to use something like thor to parameterize tasks
            #and run them in dat_sauce. The problem here is that this implementation is calling a parameter specific to thor. This should probably
            #be pushed into custom definable tasks simillar to the Cucumber::Rake::Task that cucumber has implemented for rake.
            #I am doing it like this for the moment to save on time and will come back to re-implement this correctly at a later date.
            io = Object::IO.popen("#{cmd} --file #{test}")
            Process.wait2(io.pid)
            _results = process_temp_file io
          end

          JSON.parse(_results)
        end

        private


        def process_temp_file(file)
          results = ''
          until file.eof?
            results << file.gets
          end
          results
        end
      end

    end
  end


end