require_relative "spec_helper"


describe "Results Parser" do

  it "should parse the results" do
    results = DATSauce::Cucumber::Runner.run_test('./features/login_and_session/login.feature:8', ['-p dev'])
    puts JSON.parse(results)["failed_tests"]
    results = JSON.parse(results)["results"]
    parsed_results = DATSauce::Cucumber::ResultsParser.summarize_results(results)
    puts parsed_results
    expect(parsed_results).to_not(eql nil)
  end


end