
Dir[File.dirname(__FILE__) + '/dat_sauce/*.rb'].each {|file| require file }

module DATSauce
  # probably could store the username and key in a config file in the cucumber directory
  # may also want to think about adding support for specifying grid or sauce
  # initializer here DatSauce::CLI.new(runner, test_directory, ENV[SAUCE_USERNAME], ENV['SAUCE_KEY'], [test options] )

  # DATSauce.run_tests('Apollo', './features/login_and_session', ['-p dev_parallel', 'DRIVER=selenium', '-f Teamcity::Cucumber::Formatter'], true, 'local', nil,nil,false)
  def self.run_tests(project, test_location, test_options, rerun, event_emitter_type, record_to_database, runner_type, number_of_processes=nil, desired_caps=nil)
    # Signal.trap("INT") do
     # @test_run.stop
    # end
    tests = DATSauce::Cucumber::TestParser.parse_tests(test_location, test_options)
    @test_run = DATSauce::TestRun.new(project, test_options, tests, rerun, event_emitter_type, record_to_database, runner_type, number_of_processes, desired_caps)
    @test_run.run
    @test_run
  end
end
