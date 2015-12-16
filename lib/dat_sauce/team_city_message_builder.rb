module DATSauce

  class TCMessageBuilder
    attr_accessor :run_id, :rerun_id

      # testSuiteStarted
        # testStarted
          # testStdOut
          # testStdErr
          # testFailed
        # testFinished
      # testSuiteFinished


      MESSAGES = {
          1 => {
              :name => 'message',
              :attributes => ['text', 'errorDetails', 'status']
          },
          2 => {
              :name => 'blockOpened',
              :attributes => ['name']
          },
          3 => {
              :name => 'blockClosed',
              :attributes => ['name']
          },
          4 => {
              :name => 'testSuiteStarted',
              :attributes => ['name']
          },
          5 => {
              :name => 'testSuiteFinished',
              :attributes => ['name']
          },
          6 => {
              :name => 'testStarted',
              :attributes => ['name', 'captureStandardOutput']
          },
          7 => {
              :name => 'testFinished',
              :attributes => ['name', 'duration']
          },
          8 => {
              :name => 'testIgnored',
              :attributes => ['name', 'message']
          },
          9 => {
              :name => 'testStdOut',
              :attributes => ['name', 'out']
          },
          10 => {
              :name => 'testStdErr',
              :attributes => ['name', 'duration']
          },
          11 => {
              :name => 'testFailed',
              :attributes => ['name', 'message', 'details', 'expected', 'actual']
          },
          12 => {
              :name => 'progressMessage',
              :attributes => []
          },
          13 => {
              :name => 'progressStart',
              :attributes => []
          },
          14 => {
              :name => 'progressFinish',
              :attributes => []
          },
          15 => {
              :name => 'buildProblem',
              :attributes => ['description', 'identity']
          },
          16 => {
              :name => 'buildStatus',
              :attributes => ['status', 'text']
          },
          17 => {
              :name => 'buildStatisticValue',
              :attributes => ['key', 'value']
          }
      }

      PREFIX = '##teamcity'

      STATUS = {
          1 => 'NORMAL',
          2 => 'WARNING',
          3 => 'FAILURE',
          4 => 'ERROR'
      }

      def start_progress
        p "#{PREFIX}[progressStart '']"
      end

      def finish_progress
        p "#{PREFIX}[progressFinish '']"
      end

      def progress_message(message)
        p "#{PREFIX}[progressMessage '#{message}']"
      end

      def start_test(test_name)
        p "#{PREFIX}[testStarted name='#{test_name}' flowId='#{test_name}']"
      end

      def report_stdout(test_name, output)
        # p output
        p "#{PREFIX}[testStdOut name='#{test_name}' out='#{output}']"
      end

      def finish_test(test_name)
        p "#{PREFIX}[testFinished name='#{test_name}' flowId='#{test_name}']"
      end

      def start_test_suite(suite_name)
        p "#{PREFIX}[testSuiteStarted name='#{suite_name}']"
      end

      def finish_test_suite(suite_name)
        p "#{PREFIX}[testSuiteFinished name='#{suite_name}']"
      end

      def test_failed(params={})
        # test_name, message, details, expected, actual
        p "#{PREFIX}[testFailed name='#{params[:name]}' flowId='#{params[:name]}' message='#{params[:message]}' errorDetails='#{params[:details]}' expected='#{params[:expected]}' actual='#{params[:actual]}']"
      end

      def report_run_statistics(stats={})
        stats_string = ''
        stats.each do |key, value|
          stats_string << "key='#{key}' value='#{value}' "
        end
        p "#{PREFIX}[buildStatisticValue '#{stats_string}']"
      end

      def report_message(params)
        # message, error_details=nil, status=nil
        p "#{PREFIX}[message text='#{params[:message]}' errorDetails='#{params[:error_details]}' status='#{STATUS[params[:status]]}']"
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

  class TCEventHandler < DATSauce::EventHandler

    private

    def start_test_run(test_run)
      @tc_message_builder = TCMessageBuilder.new
      @tc_message_builder.start_test_suite test_run.run_id
      @tc_message_builder.run_id = test_run.run_id
    end

    def stop_test_run(test_run)

    end

    def start_rerun(count)
      @tc_message_builder.rerun_id = @tc_message_builder.run_id + Time.now.to_i.to_s
      @tc_message_builder.start_test_suite(@tc_message_builder.rerun_id)
    end

    def test_run_completed(test_run)
      @tc_message_builder.finish_test_suite(@tc_message_builder.rerun_id) unless @tc_message_builder.rerun_id.nil?
      @tc_message_builder.finish_test_suite(@tc_message_builder.run_id)

    end

    def start_test(test)
      @tc_message_builder.start_test test.name
    end

    def test_completed(test)
      if test.results[:rerun].nil?
        if test.results[:primary].status == 'Passed'
          @tc_message_builder.finish_test test.name
        else
          @tc_message_builder.test_failed({:name => test.name})
          @tc_message_builder.finish_test test.name
        end
      else
        if test.results[:rerun].status == 'Passed'
          @tc_message_builder.finish_test test.name
        else
          @tc_message_builder.report_stdout(test.name, @tc_message_builder.format_text(test.results[:rerun].log))
          @tc_message_builder.test_failed({:name => test.name})
          @tc_message_builder.finish_test test.name
        end
      end

    end

    def info(message)
      @tc_message_builder.report_message({:message => message})
    end


  end

end