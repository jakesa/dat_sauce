require_relative 'progress_bar_v2'

class ProgressBarEventHandler < DATSauce::EventHandler

  def initialize
    self.stdout = true
  end

  def start_test_run(test_run)
    @progress_bar = DATSauce::ProgressBar.new({:count => test_run.test_count})
    @progress_bar.start_progress
    @progress_bar.start_timer
  end

  def stop_test_run(test_run)

  end

  def test_run_completed(test_run)
    @progress_bar.finish
    #TODO: may do something with the test object here.
  end

  def test_completed(test)
    @progress_bar.increment 1

    if test.results[:rerun].nil?
      if test.results[:primary].status == 'Passed'
        @progress_bar.pass_count += 1
      else
        @progress_bar.fail_count += 1
        @progress_bar.current_failures << test.results[:primary].failed_scenarios
      end
    else
      if test.results[:rerun].status == 'Passed'
        @progress_bar.pass_count += 1
      else
        @progress_bar.fail_count += 1
        @progress_bar.current_failures << test.results[:rerun].failed_scenarios
      end
    end

  end

  def start_rerun(count)
    @progress_bar.count = count
    @progress_bar.run_type = 'rerun'
    @progress_bar.pass_count = 0
    @progress_bar.fail_count = 0
    @progress_bar.current_count = 0
    @progress_bar.current_failures = []
  end

  def info(message)
    @progress_bar.output message
  end


end