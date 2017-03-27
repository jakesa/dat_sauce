require_relative '../../../../lib/dat_sauce/event_handlers/event_handler'
require_relative 'results_service'
class DBEventHandler < DATSauce::EventHandler

  def initialize
    self.stdout = false
    @results_service = ResultsService.new
  end

  def start_test_run(test_run)
    @results_service.add_test_run test_run
  end

  def stop_test_run(test_run)
    @results_service.update_test_run test_run
  end

  def start_rerun(test_run)
    @results_service.update_test_run test_run
  end

  def test_run_completed(test_run)
    @results_service.update_test_run test_run
  end

  def test_created(test)
    @results_service.add_test test
  end

  def start_test(test)
    @results_service.start_test test
  end

  def stop_test(test)
    @results_service.update_test test
  end

  def test_completed(test)
    @results_service.add_run_to_test test
  end

end
