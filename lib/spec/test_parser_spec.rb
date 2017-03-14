require_relative 'spec_helper'

describe 'TestParser' do

  it 'should parse a list directory of tests' do
    previous_dir = Dir.pwd
    Dir.chdir './lib/spec/cucumber'
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features', ['-p default'])
    Dir.chdir previous_dir
    expect(tests).to_not(eql nil)
  end
end