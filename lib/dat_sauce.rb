require "dat_sauce/version"
require "dat_sauce/test_parser"

module DatSauce
  # probably could store the username and key in a config file in the cucumber directory
  # may also want to think about adding support for specifying grid or sauce
  # initializer here DatSauce::CLI.new(runner, test_directory, ENV[SAUCE_USERNAME], ENV['SAUCE_KEY'], [test options] )
end
