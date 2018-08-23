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
        def run_test(test_object, cmd=nil)
          # @uri, @runOptions, @runId, @runCount
          ENV["AUTOTEST"] = "1" if $stdout.tty?
          trap_interrupt
          @results = nil

          temp_file = Tempfile.new('test_run')
          #Pass in dat_pages config object?
          # id used for screen shots
          # this is leveraged by the cucumber hooks to record the presents of screen shots
          screen_shot_id = "#{test_object.screenShotId}-#{test_object.runCount}"

          if cmd.nil?
            _options = ''

            begin #TODO: need to rewrite this to be more useful
              test_object.runOptions.each do |option|
                _options += " #{option}" unless option.start_with?('.')
              end

            rescue => e
              puts 'there was an error'
              puts e
              puts e.backtrace
            end unless test_object.runOptions.nil?

            @io = Object::IO.popen("bundle exec cucumber #{test_object.uri} #{_options} -f json --out #{temp_file.path} SCREEN_SHOT_ID=#{screen_shot_id}")
            Process.wait2(@io.pid)
            @results = process_temp_file(temp_file)
          else
            #TODO - this is setup for allowing the user to pass in a command to run. This allows someone to use something like thor to parameterize tasks
            #and run them in dat_sauce. The problem here is that this implementation is calling a parameter specific to thor. This should probably
            #be pushed into custom definable tasks similar to the Cucumber::Rake::Task that cucumber has implemented for rake.
            #I am doing it like this for the moment to save on time and will come back to re-implement this correctly at a later date.
            @io = Object::IO.popen("#{cmd} --file #{test_object.uri} --output_type json --output_file #{temp_file.path}")

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
            @results = {'test' =>test_object.uri, 'message' => "unknown error. Output: #{@results}", 'status'=>'failed'}
          else
            begin
             @results = JSON.parse(@results)
            rescue JSON::ParserError
             @results = {'test'=>test_object.uri, 'message' => "JSON parse error. Output: #{@results}", 'status'=>'failed'}
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