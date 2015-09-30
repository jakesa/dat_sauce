require_relative 'spec_helper'

describe "TestParse" do

  it 'should parse a list directory of tests' do
    tests = DATSauce::Cucumber::TestParser.parse_tests('./features/login_and_session', ['-p dev'])
    # Dir.chdir "~/apollo/source/integration_tests"
    expect(tests).to_not(eql nil)
  end
end