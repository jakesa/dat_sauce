module DATSauce
  module Cucumber
    module TestParser
      class << self

        def parse_tests(test_directory, options)
          raise "#{test_directory} does not exist" unless Dir.exist? test_directory
          tests = dry_run([test_directory, options].compact.join(" ")).split("\n")
          # puts tests
          refined_tests =[]
          tests.delete_at(0) if tests[0].downcase.include?('using')
          tests.each do |test|
            refined_tests << test.gsub('\\','/')
          end
          $stdout << "The number of scenarios found to be executed: #{refined_tests.count}"
          $stdout << "\n"
          refined_tests
        end

        private

        def dry_run(cmd)
          $stdout << "Preprocessing test files"
          $stdout << "\n"

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