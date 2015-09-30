require_relative 'spec_helper'

describe "TestRunner" do

  it 'should run a test' do
    results = DATSauce::Cucumber::Runner.run_test('./features/login_and_session/login.feature:8', ['-p dev_parallel'])
    puts JSON.parse(results)["results"]
    expect(results).to_not(eq nil)
  end


end