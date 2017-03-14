require_relative 'spec_helper'


describe 'Results Parser' do
 #TODO: might want to make these tests look for specific values rather than just looking to see if the key is in the hash
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
  end

  it 'should parse the results' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.class).to eq Hash
  end

  it 'should have the raw json stored in json_results' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :json_results).to eq true
  end

  it 'should have a list of scenarios executed' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :scenario_list).to eq true
  end

  it 'should have the pass count' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :pass_count).to eq true
  end

  it 'should have the fail count' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :fail_count).to eq true
  end

  it 'should have the undefined count' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :undefined_count).to eq true
  end

  it 'should have the pending count' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :pending_count).to eq true
  end

  it 'should have the failed scenarios list' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :failed_scenarios).to eq true
  end

  it 'should have the run time' do
    results = JSON.parse(@file)
    results = DATSauce::ResultsParser::Cucumber.summarize_json_results(results)
    expect(results.keys.include? :run_time).to eq true
  end

end


