require_relative 'team_city_message_builder'


class TCEventHandler < DATSauce::EventHandler

  def initialize
    self.stdout = true
  end

  def start_test_run(test_run)
    @tc_message_builder = DATSauce::TCMessageBuilder.new
    render_output @tc_message_builder.start_test_suite test_run.runId
    @tc_message_builder.run_id = test_run.runId
  end

  def stop_test_run(test_run)

  end

  def start_rerun(test_run)
    @tc_message_builder.rerun_id = @tc_message_builder.run_id + Time.now.to_i.to_s
    render_output @tc_message_builder.start_test_suite(@tc_message_builder.rerun_id)
  end

  def test_run_completed(test_run)
    render_output @tc_message_builder.finish_test_suite(@tc_message_builder.rerun_id) unless @tc_message_builder.rerun_id.nil?
    render_output @tc_message_builder.finish_test_suite(@tc_message_builder.run_id)
  end


  def test_completed(test)
    if test.results[:rerun].nil?
      if test.results[:primary].status == 'Passed'
        render_output "#{@tc_message_builder.start_test(test.name)}\n#{@tc_message_builder.finish_test(test.name)}"
      else
        render_output "#{@tc_message_builder.start_test(test.name)}\n#{@tc_message_builder.test_failed({:name => test.name})}\n#{@tc_message_builder.finish_test(test.name)}"
      end
    else
      if test.results[:rerun].status == 'Passed'
        render_output "#{@tc_message_builder.start_test(test.name)}\n#{@tc_message_builder.finish_test(test.name)}"
      else
        flow_id = test.name + Time.now.to_i.to_s
        render_output "#{@tc_message_builder.start_test(test.name, flow_id)}\n#{@tc_message_builder.report_stdout(test.name, @tc_message_builder.format_text(test.results[:rerun].log),flow_id)}\n#{@tc_message_builder.test_failed({:name => test.name, :flow_id => flow_id})}\n#{@tc_message_builder.finish_test(test.name, flow_id)}"
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