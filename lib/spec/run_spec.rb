require_relative 'spec_helper'

describe 'DATSauce' do

  it 'should work' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features/login_and_session', ['-p dev_parallel'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel'], true, tests, nil, 'local', nil)
    test_run.run
  end

  it 'should run a single file test' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features/login_and_session/login.feature', ['-p dev_parallel'])
    test_run = DATSauce::TestRun.new('Apollo', ['-p dev_parallel'], true, tests, nil, 'local', nil)
    test_run.run
  end


end