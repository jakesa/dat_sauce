require_relative 'spec_helper'

describe 'DATSauce' do

  it 'should work' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features', ['-p dev_parallel', 'DRIVER=sauce'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel', 'DRIVER=sauce'], tests, true, 'progress_bar', false, 'local')
    test_run.run
  end

  it 'should run a single file test' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features/login_and_session', ['-p dev_parallel', 'DRIVER=selenium'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel', 'DRIVER=selenium', '-f Teamcity::Cucumber::Formatter'], tests, true, 'progress_bar', false, 'local')
    test_run.run
  end

  it 'should report to Teamcity' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features/login_and_session/login.feature', ['-p dev_parallel', 'DRIVER=selenium'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel', 'DRIVER=selenium'], tests, true, 'progress_bar', false, 'local', 4)
    test_run.run
  end

  it 'should use the new event emitter' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features/login_and_session', ['-p dev_parallel', 'DRIVER=selenium'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel', 'DRIVER=selenium'], tests, true, 'progress_bar', false, 'local', 4)
    test_run.run
  end

end