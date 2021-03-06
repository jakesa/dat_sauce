
Dir[File.dirname(__FILE__) + '/dat_sauce/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/dat_sauce/dat_results/*.rb'].each {|file| require file }

module DATSauce
  # {
  #     :project_name => String, #name of the project
  #     :run_options => Array, #an array of cucumber options
  #     :tests => Array, #an array of tests to be run
  #     :rerun => String, #serial or parallel (s/p) tells the application whether or not you want to do a rerun of the failures and if you want them to be run in serial or parallel
  #     :outputs => String, #tells the system how you want the progress and the results displayed to the user
  #     :run_location => Hash, #{:location, :desired_caps}
  #     :number_of_processes => Integer, #the number of concurrent processes you want running tests. Performance will decrease the higher you go. Typically, 2 times the number of physical cores is the ceiling
  # }
  # TODO: Accept a cucumber run command or default to bundle exec cucumber #{run_options}
  def self.run_tests(hash)
    hash[:tests] = DATSauce::Cucumber::TestParser.parse_tests(hash[:test_directory], hash[:run_options])
    parse_handlers(hash)
    @test_run = DATSauce::TestRun.new(hash)
    @test_run.run
    @test_run
  end

  def self.config
    @config ||= DATSauce::Config.new
  end

  def self.record_screen_shot(url, file_path, file_name)
    DATResults::ScreenShot.new(url).record_screen_shot(file_path, file_name)
  end

  private
  # set the database config info if that info is passed in
  def self.parse_handlers(options)
    if options[:outputs].include? 'database'
      config.database_address = options[:database_address] if options[:database_address]
      config.database_port = options[:database_port] if options[:database_port]
    end
  end

end
