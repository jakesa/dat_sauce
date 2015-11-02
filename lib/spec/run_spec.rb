require_relative 'spec_helper'

describe 'DATSauce' do

  it 'should work' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features', ['-p dev_parallel', 'DRIVER=sauce'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel', 'DRIVER=sauce'], true, tests, nil, 'sauce', nil)
    test_run.run
  end

  it 'should run a single file test' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features/login_and_session', ['-p dev_parallel', 'DRIVER=selenium'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel', 'DRIVER=selenium', '-f Teamcity::Cucumber::Formatter'], true, tests, nil, 'local', nil, false)
    test_run.run
  end


end