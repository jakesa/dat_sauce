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
        # test_name, message, details, expected, actual
        # p "#{PREFIX}[testFailed name='#{params[:name]}' flowId='#{params[:name]}' message='#{params[:message]}' errorDetails='#{params[:details]}' expected='#{params[:expected]}' actual='#{params[:actual]}']"
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
        # message, error_details=nil, status=nil
        # error_details = "errorDetails='#{params[:error_details]}'" unless params[:error_details].nil?
        # status = "status=#{STATUS[params[:status]]}" unless params[:status].nil?
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

  class TCEventHandler < DATSauce::EventHandler

    private

    def start_test_run(test_run)
      @tc_message_builder = TCMessageBuilder.new
      render_output @tc_message_builder.start_test_suite test_run.run_id
      @tc_message_builder.run_id = test_run.run_id
    end

    def stop_test_run(test_run)

    end

    def start_rerun(count)
      @tc_message_builder.rerun_id = @tc_message_builder.run_id + Time.now.to_i.to_s
      render_output @tc_message_builder.start_test_suite(@tc_message_builder.rerun_id)
    end

    def test_run_completed(test_run)
      render_output @tc_message_builder.finish_test_suite(@tc_message_builder.rerun_id) unless @tc_message_builder.rerun_id.nil?
      render_output @tc_message_builder.finish_test_suite(@tc_message_builder.run_id)

    end

    # def start_test(test)
    #   @tc_message_builder.start_test test.name
    # end

    def test_completed(test)
      if test.results[:rerun].nil?
        if test.results[:primary].status == 'Passed'
          render_output "#{@tc_message_builder.start_test(test.name)}\n#{@tc_message_builder.finish_test(test.name)}"

          # @tc_message_builder.finish_test test.name
        else
          render_output "#{@tc_message_builder.start_test(test.name)}\n#{@tc_message_builder.test_failed({:name => test.name})}\n#{@tc_message_builder.finish_test(test.name)}"
          # @tc_message_builder.test_failed({:name => test.name})
          # @tc_message_builder.finish_test test.name
        end
      else
        if test.results[:rerun].status == 'Passed'
          render_output "#{@tc_message_builder.start_test(test.name)}\n#{@tc_message_builder.finish_test(test.name)}"
        else
          flow_id = test.name + Time.now.to_i.to_s
          render_output "#{@tc_message_builder.start_test(test.name, flow_id)}\n#{@tc_message_builder.report_stdout(test.name, @tc_message_builder.format_text(test.results[:rerun].log),flow_id)}\n#{@tc_message_builder.test_failed({:name => test.name, :flow_id => flow_id})}\n#{@tc_message_builder.finish_test(test.name, flow_id)}"
          # @tc_message_builder.report_stdout(test.name, @tc_message_builder.format_text(test.results[:rerun].log))
          # @tc_message_builder.test_failed({:name => test.name})
          # @tc_message_builder.finish_test test.name
        end
      end

    end

    def info(message)
      render_output @tc_message_builder.report_message({:message => message})
    end

    def render_output(output)
      $stdout.puts output
      $stdout.flush
    end


  end

end