require 'tempfile'
module DATSauce
  module Cucumber
    module TestParser
      class << self
        Thread.abort_on_exception = true

        def parse_tests(test_directory, options)
          # tests = dry_run([test_directory, options].compact.join(" ")).split("\n")
          tests = json_dry_run([test_directory, options].compact.join(" "))
          refined_tests = parse_json(tests)
          # while tests[0].downcase.include?('using') || tests[0].downcase.include?('Using')
          #   tests.delete_at(0)
          # end

          # tests.each do |test|
          #   refined_tests << test.gsub('\\','/')
          # end
          puts "The number of scenarios found to be executed: #{refined_tests.count}"
          refined_tests
        end

        private

        def parse_json(results)
          # {
          #     uri: '', #this is the feature location
          #     id: '', #the id generated by the json output
          #     line: '', #the line number where the test starts
          # }
          tests = []
          results.each do |feature|
            uri = feature['uri']
            feature['elements'].each do |scenario|
              unless scenario['keyword'] == 'Background'
                test = {}
                test[:uri] = uri
                test[:id] = scenario['id']
                test[:line] = scenario['line']
                test[:name] = scenario['name']
                tests << test
              end
            end
          end
          tests
        end

        def json_dry_run(cmd)
          puts 'Processing test files'

          # this takes out any formatters that were passed in while keeping the relevant run options
          temp_file = Tempfile.new('test_run')
          outputs = cmd.scan(/-f \S+/)
          outputs.each do |output|
            cmd.gsub!(output, "")
          end

          cmd = "bundle exec cucumber --dry-run #{cmd} -f json --out #{temp_file.path}"
          tr = Thread.new(cmd) { |c| `#{c}`}
          tr.join(30)
          JSON.parse process_temp_file temp_file
        end

        def process_temp_file(file)
          results = ''
          until file.eof?
            results << file.gets
          end
          results
        end

      end
    end
  end
end