module DATSauce
  module Cucumber
    module TestParser
      class << self

        # TODO: convert this to JSON??
        def parse_tests(test_directory, options)
          # raise "#{test_directory} does not exist" unless File.exist?(test_directory)
          # raise "#{test_directory} does not exist" unless Dir.exist? test_directory
          tests = dry_run([test_directory, options].compact.join(" ")).split("\n")
          refined_tests =[]
          while tests[0].downcase.include?('using') || tests[0].downcase.include?('Using')
            tests.delete_at(0)
          end

          tests.each do |test|
            refined_tests << test.gsub('\\','/')
          end
          puts "The number of scenarios found to be executed: #{refined_tests.count}"
          refined_tests
        end

        private

        def dry_run(cmd)
          puts 'Preprocessing test files'

          outputs = cmd.scan(/-f \S+/)
          outputs.each do |output|
            cmd.gsub!(output, "")
          end

          cmd = "bundle exec cucumber --dry-run -f DryRunFormatter #{cmd}"
          # puts cmd
          tr = Thread.new(cmd) { |c| `#{c}`}
          tr.join
          tr.value
        end
      end
    end
  end
end