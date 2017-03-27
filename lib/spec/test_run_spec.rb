require_relative '../../lib/dat_sauce'

describe 'DATSauce' do

  before :all do
    # params = {
    #     :project_name => String, #name of the project
    #     :run_options => Array, #an array of cucumber options
    #     :tests => Array, #an array of tests to be run
    #     :rerun => String, #serial or parallel (s/p) tells the application whether or not you want to do a rerun of the failures and if you want them to be run in serial or parallel
    #     :event_emitter_type => String, #tells the system how you want the progress and the results displayed to the user
    #     :run_location => {:location => 'local'}, #{:location, :desired_caps}
    #     :number_of_processes => 8, #the number of concurrent processes you want running tests. Performance will decrease the higher you go. Typically, 2 times the number of physical cores is the ceiling
    # }
    @params = {
        :project_name => 'Apollo',
        :run_options => ["-p default"],
        :test_directory=> File.expand_path('./cucumber/features', File.dirname(__FILE__)),
        :rerun => 'parallel',
        :outputs => ['default'],
        :run_location => {:location => 'local'},
        :number_of_processes => 10
    }
  end

  it 'should work' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    DATSauce.run_tests(@params)
    Dir.chdir previous_dir
  end

  it 'should run a single file test' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'

    @params[:test_directory] = File.expand_path('./cucumber/features/passing_scenarios.feature:8', File.dirname(__FILE__))

    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.status).to eq 'Completed'
  end

  it 'should run from dat_sauce gem' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.status).to eq 'Completed'
  end

  it 'should run multiple test files' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    file_1 = File.expand_path('./cucumber/features/passing_scenarios.feature', File.dirname(__FILE__))
    file_2 = File.expand_path('./cucumber/features/passing_scenario_outlines.feature', File.dirname(__FILE__))
    @params[:test_directory] = [file_1, file_2]
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.status).to eq 'Completed'
  end

  it 'should rerun if there are failures' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    file_1 = File.expand_path('./cucumber/features/failing_scenarios.feature', File.dirname(__FILE__))
    @params[:test_directory] = file_1
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.results[:rerun]).to_not eq nil
  end

  it 'should have a run_id' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    file_1 = File.expand_path('./cucumber/features/passing_scenarios.feature:8', File.dirname(__FILE__))
    @params[:test_directory] = file_1
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.runId).to_not eq nil
  end

  it 'should have a project_name' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    file_1 = File.expand_path('./cucumber/features/passing_scenarios.feature:8', File.dirname(__FILE__))
    @params[:test_directory] = file_1
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.projectName).to eq 'Apollo'
  end

  it 'should have a test count' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    file_1 = File.expand_path('./cucumber/features/passing_scenarios.feature:8', File.dirname(__FILE__))
    @params[:test_directory] = file_1
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.testCount).to eq 1
  end

  it 'should have a status' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    file_1 = File.expand_path('./cucumber/features/passing_scenarios.feature:8', File.dirname(__FILE__))
    @params[:test_directory] = file_1
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.status).to eq 'Completed'
  end

  it 'should have run_options' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    file_1 = File.expand_path('./cucumber/features/passing_scenarios.feature:8', File.dirname(__FILE__))
    @params[:test_directory] = file_1
    test_run = DATSauce.run_tests(@params)
    Dir.chdir previous_dir
    expect(test_run.runOptions).to_not eq nil
  end

  it 'should have a queue_size' do

  end

end
