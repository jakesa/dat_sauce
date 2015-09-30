require_relative 'spec_helper'

describe 'Test' do

  it 'should be initialized with a run_id, test_name and test_options' do
    test = DATSauce::Test.new 'run_1234', 'This is a test', ['-p test, -o options']
    expect(test.run_id).to(eq 'run_1234')
    expect(test.name).to(eq 'This is a test')
    expect(test.test_options).to_not(eq nil)
  end

  it 'should return a hash' do
    test = DATSauce::Test.new 'run_1234', 'This is a test', ['-p test, -o options']
    expect(test.to_hash).to_not(eq nil)
    expect(test.to_hash.class).to(eq Hash)
  end

  it 'should return a JSON string' do
    test = DATSauce::Test.new 'run_1234', 'This is a test', ['-p test, -o options']
    expect(test.to_json).to_not(eq nil)
    expect(test.to_json.class).to(eq String)
  end

end