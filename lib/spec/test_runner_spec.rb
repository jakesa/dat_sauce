require_relative 'spec_helper'

describe 'TestRunner' do

  it 'should respond to #run_test' do
    expect(DATSauce::Cucumber::Runner.respond_to? :run_test).to eq true
  end

end