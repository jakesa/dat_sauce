require 'ruby-progressbar'
Dir[File.dirname(__FILE__) + '/dat_sauce/*.rb'].each {|file| require file }

module DATSauce
  # probably could store the username and key in a config file in the cucumber directory
  # may also want to think about adding support for specifying grid or sauce
  # initializer here DatSauce::CLI.new(runner, test_directory, ENV[SAUCE_USERNAME], ENV['SAUCE_KEY'], [test options] )

  # DATSauce.run_tests('Apollo', './features/login_and_session', ['-p dev_parallel', 'DRIVER=selenium', '-f Teamcity::Cucumber::Formatter'], true, 'local', nil,nil,false)
  def self.run_tests(project, test_location, test_options, rerun, runner_type, event_emitter, desired_caps, number_of_processes)
    # Signal.trap("INT") do
     # @test_run.stop
    # end
    tests = DATSauce::Cucumber::TestParser.parse_tests(test_location, test_options)
    @test_run = DATSauce::TestRun.new(project, run_options, rerun, tests, event_emitter, runner_type, desired_caps, number_of_processes)
    @test_run.run
  end
end
