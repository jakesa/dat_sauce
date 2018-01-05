require 'cucumber'
require 'tempfile'
require 'json'
module DATSauce
  module Cucumber
    module Runner
      class << self
        Thread.abort_on_exception = true
        # TODO - need to add logic for detecting errors?
        # Should I move the even emitter into this runner and emit the start/stop event in here?
        def run_test(test, options, run_id = nil, cmd=nil)
          ENV["AUTOTEST"] = "1" if $stdout.tty?
          trap_interrupt
          @results = nil

          temp_file = Tempfile.new('test_run')
          #Pass in dat_pages config object?

          if cmd.nil?
            _options = ''

            begin #TODO: need to rewrite this to be more useful
              options.each do |option|
                _options += " #{option}" unless option.start_with?('.')
              end

            rescue => e
              puts 'there was an error'
              puts e
              puts e.backtrace
            end unless options.nil?

            @io = Object::IO.popen("bundle exec cucumber #{test} #{_options} -f json --out #{temp_file.path}")
            Process.wait2(@io.pid)
            @results = process_temp_file(temp_file)
          else
            #TODO - this is setup for allowing the user to pass in a command to run. This allows someone to use something like thor to parameterize tasks
            #and run them in dat_sauce. The problem here is that this implementation is calling a parameter specific to thor. This should probably
            #be pushed into custom definable tasks similar to the Cucumber::Rake::Task that cucumber has implemented for rake.
            #I am doing it like this for the moment to save on time and will come back to re-implement this correctly at a later date.
            @io = Object::IO.popen("#{cmd} --file #{test} --output_type json --output_file #{temp_file.path}")

            begin
              Process.wait2(@io.pid)
            rescue
              nil
            end
            @results = process_temp_file temp_file
          end

          if @results.empty? && @stopped
           @results = {'message' => 'stopped', 'status' =>'stopped'}
          elsif @results.empty? && !@stopped
            @results = {'test' =>test, 'message' => "unknown error. Output: #{@results}", 'status'=>'failed'}
          else
            begin
             @results = JSON.parse(@results)
            rescue JSON::ParserError
             @results = {'test'=>test, 'message' => "JSON parse error. Output: #{@results}", 'status'=>'failed'}
            end
          end
          @results
        end

        private

        def trap_interrupt
          p = trap('INT') do
            # puts 'Trapped INT signal' #debug
            begin
              @stopped = true
              Process.kill(9, @io.pid) unless @io.pid.nil?
              # @io.puts '__END__'
            rescue => e
              # puts e.message #debug
              p.call
            end
            #putting exit(2) here kills the entire top level process without running any other code
            p.call
          end
        end

        def process_temp_file(file)
          results = ''
            until file.eof?
              str = file.gets
              results << str
            end
          results
        end
      end
    end
  end


end