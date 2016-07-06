module DATSauce

  class TCMessageBuilder
    attr_accessor :run_id, :rerun_id

      PREFIX = '##teamcity'

      STATUS = {
          1 => 'NORMAL',
          2 => 'WARNING',
          3 => 'FAILURE',
          4 => 'ERROR'
      }

      def start_progress
        "#{PREFIX}[progressStart '']"
      end

      def finish_progress
        "#{PREFIX}[progressFinish '']"
      end

      def progress_message(message)
        "#{PREFIX}[progressMessage '#{message}']"
      end

      def start_test(test_name, flow_id = nil)
        "#{PREFIX}[testStarted name='#{test_name}' flowId='#{flow_id.nil? ? test_name : flow_id}']"
      end

      def report_stdout(test_name, output, flow_id = nil)
        "#{PREFIX}[testStdOut name='#{test_name}' flowId='#{flow_id.nil? ? test_name : flow_id}' out='#{output}']"
      end

      def finish_test(test_name, flow_id = nil)
        "#{PREFIX}[testFinished name='#{test_name}' flowId='#{flow_id.nil? ? test_name : flow_id}']"
      end

      def start_test_suite(suite_name)
        "#{PREFIX}[testSuiteStarted name='#{suite_name}']"
      end

      def finish_test_suite(suite_name)
        "#{PREFIX}[testSuiteFinished name='#{suite_name}']"
      end

      def test_failed(params={})
        "#{PREFIX}[testFailed name='#{params[:name]}' flowId='#{params[:flow_id].nil? ? params[:name] : params[:flow_id]}']"
      end

      def report_run_statistics(stats={})
        stats_string = ''
        stats.each do |key, value|
          stats_string << "key='#{key}' value='#{value}' "
        end
        "#{PREFIX}[buildStatisticValue '#{stats_string}']"
      end

      def report_message(params)
        "#{PREFIX}[message text='#{params[:message]}']"
      end

      def format_text(text)
        new_text = text
        list = {
            "|" => "||",
            "'" => "|'",
            "\n" => "|n",
            "\r" => "|r",
            "[" => "|[",
            "]" => "|]"
        }

        list.each do |key, value|
          new_text = new_text.gsub key, value
        end
        new_text
      end

  end

end
