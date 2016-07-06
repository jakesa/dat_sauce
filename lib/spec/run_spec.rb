require_relative '../../lib/dat_sauce'

describe 'DATSauce' do

  it 'should work' do
    # params = {
    #     :project_name => String, #name of the project
    #     :run_options => Array, #an array of cucumber options
    #     :tests => Array, #an array of tests to be run
    #     :rerun => String, #serial or parallel (s/p) tells the application whether or not you want to do a rerun of the failures and if you want them to be run in serial or parallel
    #     :event_emitter_type => String, #tells the system how you want the progress and the results displayed to the user
    #     :run_location => {:location => 'local'}, #{:location, :desired_caps}
    #     :number_of_processes => 8, #the number of concurrent processes you want running tests. Performance will decrease the higher you go. Typically, 2 times the number of physical cores is the ceiling
    # }
    params = {
            :project_name => 'Apollo',
            :run_options => ["-p default", "DRIVER=selenium"],
            :test_directory=> './features/login_and_session/login.feature',
            :rerun => 'parallel',
            :outputs => 'progress_bar',
            :run_location => {:location => 'local'},
            :number_of_processes => 10
        }
    # params[:tests] = DATSauce::Cucumber::TestParser.parse_tests(params[:test_directory], params[:run_options])
    # test_run = DATSauce::TestRun.new(params)
    # test_run.run
    DATSauce.run_tests(params)
  end

  it 'should run a single file test' do

  end

  it 'should report to Teamcity' do

  end

  it 'should use the new event emitter' do

  end

  it 'should run from dat_sauce gem' do

  end

end