require_relative 'spec_helper'
describe 'Test Run Result' do

  before :all do
    file_name = File.expand_path('./cucumber/test_results.json', File.dirname(__FILE__))
    unless File.exists? file_name
      @params = {
          :project_name => 'Apollo',
          :run_options => ["-p default"],
          :test_directory=> File.expand_path('./cucumber/features', File.dirname(__FILE__)),
          :rerun => 'parallel',
          :outputs => 'default',
          :run_location => {:location => 'local'},
          :number_of_processes => 10
      }

      previous_dir = Dir.pwd
      Dir.chdir './lib/spec/cucumber'
      begin
        Cucumber::Cli::Main.new(['-pdefault']).execute!
      rescue SystemExit
        #cucumber throws a system exit. I need to catch it here or it will end the tests
      end
      Dir.chdir previous_dir
    end
    @file ||= File.read(file_name)
    results = JSON.parse(@file)
    @result_1 = DATSauce::TestResult.new results, Time.now, 1, 'primary'
    @result_2 = DATSauce::TestResult.new results, Time.now, 2, 'primary'
    @run_result = DATSauce::TestRunResult.new [@result_1, @result_2], Time.now, 1, 'primary'
  end

  it 'create a TestResult object' do
    expect(@run_result.class).to eq DATSauce::TestRunResult
  end

  it 'should respond to #to_json' do
    expect(@run_result.respond_to? :to_json).to eq true
  end

  specify '#to_json should return a json string' do
    expect(@run_result.to_json.class).to eq String
  end

  it 'should respond to #to_hash' do
    expect(@run_result.respond_to? :to_hash).to eq true
  end

  specify '#to_hash should return a hash' do
    expect(@run_result.to_hash.class).to eq Hash
  end

  it 'should respond to #to_s' do
    expect(@run_result.respond_to? :to_s).to eq true
  end

  specify '#to_s should return a string' do
    expect(@run_result.to_s.class).to eq String
  end

  specify '#to_s should take a parameter (log: boolean)' do
    expect(@run_result.to_s(false)).to be_truthy
  end

end