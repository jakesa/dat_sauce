# require_relative "../../lib/dat_sauce/test_parser"
# require_relative "../dat_sauce/test_runner"
# require_relative "../dat_sauce/results_parser"
require 'rspec'
Dir[File.dirname(__FILE__) + '/../dat_sauce/*.rb'].each {|file| require file }