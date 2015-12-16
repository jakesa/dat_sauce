require_relative 'base_test'
require_relative 'progress'
require_relative 'event_emitter'

# TestRunObject?
# {
#     run_id: "unique run id for the test run (include a time stamp for uniqueness?)",
#     category: "Primary run, Rerun"
# project: "Apollo, RateView, Siebel, DAT Trucker, ALM"
# test_count: "Number of individual tests to be run",
#     test_run_status: "Started", "Stopped", "Complete",
#     pass_count: "the current number of tests that have passed",
#     fail_count: "The current number of tests that have failed",
#     test_failures: "an array of the rerun output generated by each test run",
#     rerun: "boolean value stating whether or not this test run will rerun the failed tests",
#     run_options: "an array of options that are used for this test" -- I currently have this property on the test object. May not need it in both places
#
# }

module DATSauce
  class TestRun < BaseTest

    custom_attr_accessor :run_id, :project, :test_count, :test_run_status, :rerun, :run_options,
                         :tests, :runner_type, :desired_caps, :queue_size, :results, :status


    # TODO: write a args parser for this instead of hard coding all of the attr_accessor values.
    # I really want to store these in a json config file.
    def initialize(project, run_options, tests, rerun, event_emitter_type, record_to_database, runner_type, number_of_processes=nil, desired_caps=nil)
      @project = project
      @tests = tests
      @test_count = @tests.length
      @run_options = run_options
      @rerun = rerun
      @results = {:primary => nil, :rerun => nil}
      @run_id = generate_run_id
      @event_emitter = DATSauce::EventEmitter.new(event_emitter_type, record_to_database)
      @runner_type = runner_type
      @desired_caps = desired_caps
      @status = 'Initialized'
      @number_of_processes = number_of_processes
    end

    def run
      @status = 'Started'
      start_test_run(create_test_objects(@tests, @run_options, @run_id))
      puts summarize_results
    end

    def stop
      #TODO: implement this for a graceful shutdown of the test run.
    end

    private

    def create_test_objects(tests, run_options, run_id = @run_id)
      @event_emitter.emit_event(:info => "Creating test objects")
      test_objects = []
      tests.each do |test|
        test_object = DATSauce::Test.new(run_id, test, run_options)
        test_objects << test_object
        @event_emitter.emit_event(:test_creation => test_object)
      end
      test_objects
    end

    def get_queue_size
      # puts "Getting queue size: "
      if @number_of_processes
        @queue_size = @number_of_processes
      elsif @runner_type == 'sauce'
        # get max concurrent tests from sauce and assign to @queue_size
        @queue_size = 50 #this is hard coded for now. Will change later
      elsif @runner_type == 'grid'
        # get max nodes from grid
      elsif @runner_type == 'local'
        @queue_size = DATSauce::PlatformUtils.processor_count * 2
        # get max threads from platform utils
      end
      # puts "Size: #{@queue_size}"
      @queue_size
    end

    def start_test_run(test_objects)

      @event_emitter.emit_event :start_test_run => self
      @event_emitter.emit_event :info => 'Starting test run'
      @status = "Running"
      start_time = Time.now
      threads = []
      get_queue_size.times do
        test = get_next_test(test_objects)
        threads << run_test(test) unless test.nil?
        sleep 0.5 #this is an attempt at a stop gap for the account rental service not being able to handle multiple requests at once (accounts are being rented out when they should not be)
      end
      start_queue(test_objects, threads)
      process_run_results(test_objects, :primary, start_time)
      if @rerun
        @event_emitter.emit_event :info => 'This test run has been flagged for rerun. Starting rerun...'
        if there_are_failures?(test_objects)
          _start_time = Time.now
          start_rerun(test_objects)
          process_run_results(test_objects, :rerun, _start_time)
        else
          @event_emitter.emit_event :info => 'There were no failures detected. A rerun is not necessary and will not be run.'
        end
      end

      @results[:run_time] = Time.now - start_time
      @event_emitter.emit_event :test_run_completed => self
    end

    def there_are_failures?(test_objects)
      test_objects.each do |test|
        return true if test.status == 'Failed' && test.run_count <= 1
      end
      false
    end

    def start_rerun(test_objects)
      threads = []
      rerun_count = get_rerun_count(test_objects)
      # this logic is redundant. We check for failures before this method is called. Need to refactor
      @event_emitter.emit_event(:start_rerun => rerun_count)
      if rerun_count > 0
        @queue_size.times do
          test = get_next_rerun_test(test_objects)
          break if test.nil?
          threads << run_test(test)
        end
        if get_next_rerun_test(test_objects).nil?
          @event_emitter.emit_event :info => 'There are no more tests in the queue. Waiting for current tests to finish...'
          threads.each {|t| t.join}
        else
          start_rerun_queue(test_objects, threads)
        end
      else
        @event_emitter.emit_event :info => 'There were no tests to rerun'
      end

    end


    #TODO: I can probably improve the performance here by doing some kind of caching. Will revisit later
    def start_queue(test_objects, threads)
      @event_emitter.emit_event :info => 'All test processes full. Sending remaining tests to the test queue...'
      test = get_next_test(test_objects)
      while test != nil
        if get_active_thread_count(threads) < @queue_size
          threads << run_test(test)
          test = get_next_test(test_objects)
        end
      end
      @event_emitter.emit_event :info => 'Queue complete. Waiting for tests to finish running...'
      threads.each do |t|
        t.join
      end
    end

    def start_rerun_queue(test_objects, threads)
      @event_emitter.emit_event :info => 'All test processes full. Sending remaining tests to the test queue...'
      test = get_next_rerun_test(test_objects)
      while test != nil
        if get_active_thread_count(threads) < @queue_size
          threads << run_test(test)
          test = get_next_rerun_test(test_objects)
        end
      end
      @event_emitter.emit_event :info => 'Queue completed. Waiting for current tests to finish...'
      threads.each {|t| t.join}
    end

    def get_next_test(test_objects)
      test_objects.each do |test|
        if test.status == "In Queue"
          test.status = "Processing"
          return test
        end
      end
      nil
    end

    #TODO: need to revisit this, make sure its working the way I think it does
    def get_rerun_count(test_objects)
      count = 0
      test_objects.each do |test|
        if test.status == 'Failed'
          count +=1
        end
      end
      count
    end


    def get_next_rerun_test(test_objects)
      test_objects.each do |test|
        if test.status == 'Failed' && test.run_count <= 1
          test.status = 'Processing'
          return test
        end
      end
      nil
    end

    def get_active_thread_count(threads)
      threads.delete_if { |thread| !thread.alive?}
      threads.length
    end

    def run_test(test)
      Thread.new(test) {|t|
        @event_emitter.emit_event :test_started => t
        t.run
        @event_emitter.emit_event :test_completed => t

      } # event_emitter.test_completed(t) /after the test is completed emit the test completion event and send the test object to the emitter
      # this keeps the emitter out of the test object while only sending it one thread deep. Hopefully I dont run into resource conflicts here.
      # also, perhaps it would be best to do results parsing here rather than at the end of the run
    end

    #TODO - add some progress bar modifications here while the results are being processed. This appears to take a while.
    def process_run_results(test_objects, run_type, start_time)
      @event_emitter.emit_event :info => "Processing results. This may take a minute..."

      primary_results_log = ''
      primary_run_time = 0
      primary_failures = []
      rerun_results_log = ''
      rerun_failures = []
      rerun_run_time = 0
      @event_emitter.emit_event :update_stats => '' #this needs to be an object not a string. will implement later
      test_objects.each do |test|
        if run_type == :primary
          primary_results_log << test.results[:primary].log
          primary_run_time += test.results[:primary].run_time
          primary_failures << test.results[:primary].failed_tests
          results = DATSauce::Result.new({:results => primary_results_log, :failed_tests => primary_failures }, start_time)
          results.aggregate_run_time = primary_run_time
          @results[:primary] = results
        elsif run_type == :rerun
          unless test.results[:rerun].nil?
            rerun_results_log << test.results[:rerun].log
            rerun_run_time += test.results[:rerun].run_time
            rerun_failures << test.results[:rerun].failed_tests
            results = DATSauce::Result.new({:results => rerun_results_log, :failed_tests => rerun_failures }, start_time)
            results.aggregate_run_time = rerun_run_time
            @results[:rerun] = results
          end
        end
      end

    end

    def summarize_results
      puts "#############################"
      puts "Primary run results"
      puts "#{results[:primary].results_summary}"
      puts "Took #{calculate_runtime(results[:primary].run_time)}"
      puts "#############################"
      unless results[:rerun].nil?
        puts "Rerun results"
        puts "#{results[:rerun].results_summary}"
        puts "Took #{calculate_runtime(results[:rerun].run_time)}"
        puts "#############################"
        puts "Failures:"
        puts results[:rerun].failed_tests
      end
      puts "Total Runtime: #{calculate_runtime(results[:run_time])}"
    end


    def calculate_runtime(time)
      Time.at(time).utc.strftime("%H:%M:%S")
      # [total_time / 3600, total_time/ 60 % 60, total_time % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')
    end

    def generate_run_id
      @project + "#{Time.now.to_i.to_s}"
    end


  end


end