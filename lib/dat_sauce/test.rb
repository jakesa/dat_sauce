require_relative 'custom_accessor'

module DATSauce
  class Test
    #   run_id: "The id of the run that this test object was created for"  ---- I want to use this to later link to the test run for display in the web app
    #   name: "Test name", - the name of the test
    #   test_options: ['test options'],
    #   run_time: some time in millisecond notation,
    #   status: "Done", "Running", "In Queue",
    #   results: "JSON string of results"
    extend CustomAccessor
    custom_attr_accessor :run_id, :name, :test_options, :status, :results, :run_count

    def initialize(run_id, name, test_options)
      @run_id = run_id
      @run_count = 0
      @name = name
      @test_options = test_options
      @status = "In Queue"
      @results = {:primary => nil, :rerun => nil}
    end

    # run the test
    def run
      @run_count += 1
      @status = "Running"
      time = Time.now
      process_results(DATSauce::Cucumber::Runner.run_test(@name, @test_options, nil), time)
    end

    #--
    # TODO - add a module for the to_hash, to_json and to_s methods. They are used by the Test, Result TestRun objects
    # need to change Test.attrs to self.class.attrs to make sure that the context is correct.
    #++

    # convert the test object properties to a hash
    # @return [Hash<Symbol, String>]
    def to_hash
      obj = {}
      Test.attrs.each do |attr| #need to fix this. this looks at the Test class specifically and not whatever child class called it
        obj[attr] = send(attr)
      end
      obj
    end

    # convert the test object properties into a json string
    # @return [String]
    def to_json
      JSON.generate to_hash
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

      if @run_count <= 1
        results = DATSauce::Result.new(results, start_time, @run_id, 'primary')
        @results[:primary] = results
        @status = results.status
      else
        results = DATSauce::Result.new(results, start_time, @run_id, 'rerun')
        @results[:rerun] = results
        @status = results.status
      end

    end

  end


end
