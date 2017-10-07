require_relative 'custom_accessor'
require_relative 'test_result'
require_relative 'test_runner'


module DATSauce
  class Test
    #   run_id: "The id of the run that this test object was created for"  ---- I want to use this to later link to the test run for display in the web app
    #   name: "Test name", - the name of the test
    #   test_options: ['test options'],
    #   run_time: some time in millisecond notation,
    #   status: "Done", "Running", "In Queue",
    #   results: "JSON string of results"
    #TODO: consider adding a last_run timestamp for use in the database
    extend CustomAccessor
    custom_attr_accessor :runId, :uri, :runOptions, :status, :results, :runCount, :testId, :runDate, :name, :lastRun, :lineNumber

    def initialize(run_id, test, run_options)
      @runId = run_id
      @runCount = 0
      @lineNumber = test[:line]
      @uri = "#{test[:uri]}:#{test[:line]}"
      @name = test[:name]
      @testId = test[:id]
      @runOptions = run_options
      @status = 'In Queue'
      @results = {:primary => nil, :rerun => nil}
      @runDate = Time.now.to_i * 1000 #this is epoch
      @lastRun = nil
    end

    # run the test
    # return value doesnt matter
    def run(cmd=nil)
      p = trap('INT') do
        p = -> {raise SignalException, 'INT'} unless p.respond_to? :call
        while @out.empty?
          sleep 1
        end
        p.call
      end
      @runCount += 1
      @status = 'Running'
      time = Time.now
      @lastRun = time.to_i * 1000 #epoch
      @out = ''
      #returns JSON
      @out = DATSauce::Cucumber::Runner.run_test(@uri, @runOptions, @runId, cmd)
      if @out.include? 'message'
        @status = 'Stopped'
      else
        process_results(@out, time) unless @out.nil?
      end
    end

    #--
    # TODO - add a module for the to_hash, to_json and to_s methods. They are used by the Test, Result TestRun objects
    # need to change Test.attrs to self.class.attrs to make sure that the context is correct.
    #++

    # convert the test object properties to a hash
    # @return [Hash<Symbol, String>]
    def to_hash
      obj = {}
      Test.attrs.each do |attr|
        obj[attr] = send(attr)
      end
      obj
    end

    # convert the test object properties into a json string
    # @return [String]
    def to_json
      hash  = to_hash
      results = {primary: nil, rerun: nil}
      results[:primary] = hash[:results][:primary].to_json unless hash[:results][:primary].nil?
      results[:rerun] = hash[:results][:rerun].to_json unless hash[:results][:rerun].nil?
      hash[:results] = results
      JSON.generate hash
    end

    # output the properties of the test object as a string to the console
    # @param [Boolean] log tell the method whether or not to also out put the log. Off by default because the log and be verbose
    def to_s(log = false)
      str = ''
      Test.attrs.each do |attr| #need to fix this. this looks at the Test class specifically and not whatever child class called it
        str << "#{attr}: #{send(attr)}\n" unless attr == :log && !log
      end
      $stdout << str
    end

    private

    # process the results from the test run
    def process_results(results, start_time)
      #TODO: need to pull the test_id from the results or generate it the same way as the results do
      if @runCount <= 1
        results = DATSauce::TestResult.new(results, start_time, @runId, 'primary')
        @results[:primary] = results
        @status = results.status
      else
        results = DATSauce::TestResult.new(results, start_time, @runId, 'rerun')
        @results[:rerun] = results
        @status = results.status
      end

    end

  end


end
