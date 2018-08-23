require_relative '../../../../lib/dat_sauce/event_handlers/event_handler'
require_relative 'results_service'
class DBEventHandler < DATSauce::EventHandler

  def initialize
    self.stdout = false
    @results_service = ResultsService.new DATSauce.config.database_address, DATSauce.config.database_port
  end

  def start_test_run(test_run)
    @results_service.add_test_run test_run.to_json
  end

  def stop_test_run(test_run)
    primary_id = test_run.results[:primary].nil? ? nil : test_run.results[:primary].id
    rerun_id = test_run.results[:rerun].nil? ? nil : test_run.results[:rerun].id

    run_hash = {
        id: test_run.id,
        tests: test_run.tests,
        projectId: test_run.projectId,
        status: test_run.status,
        primaryResults: primary_id,
        rerunResults: rerun_id,
        startDate: test_run.startDate,
        endDate: test_run.endDate
    }

    @results_service.update_test_run run_hash
  end

  def start_rerun(test_run)
    primary_id = test_run.results[:primary].nil? ? nil : test_run.results[:primary].id
    rerun_id = test_run.results[:rerun].nil? ? nil : test_run.results[:rerun].id

    run_hash = {
        id: test_run.id,
        tests: test_run.tests,
        projectId: test_run.projectId,
        status: test_run.status,
        primaryResults: primary_id,
        rerunResults: rerun_id,
        startDate: test_run.startDate,
        endDate: test_run.endDate
    }

    @results_service.update_test_run run_hash
  end

  def test_run_completed(test_run)
    begin
      test_run.results.each_value do |result|
        if result.nil?
          puts "The test run results were nil: #{result}"
        else
          payload = result.to_hash
          payload.delete :resultsSummary
          @results_service.record_test_run_results JSON.generate payload

        end
      end

      primary_id = test_run.results[:primary].nil? ? nil : test_run.results[:primary].id
      rerun_id = test_run.results[:rerun].nil? ? nil : test_run.results[:rerun].id

      run_hash = {
          id: test_run.id,
          tests: test_run.tests,
          projectId: test_run.projectId,
          status: test_run.status,
          primaryResults: primary_id,
          rerunResults: rerun_id,
          startDate: test_run.startDate,
          endDate: test_run.endDate
      }

      @results_service.update_test_run run_hash
    rescue => e
      $stderr.puts "There was an error: #{e}\n"
      $stderr.puts e.backtrace
    end

  end

  def test_created(test)
    @results_service.add_test test
  end

  def start_test(test)
    # @results_service.start_test test
  end

  def stop_test(test)
    @results_service.update_test test
  end

  def test_completed(test)
    @results_service.update_last_run_on_test test
    test.results.each_value do |result|
      unless result.nil?
        jre = JSON.generate({
           id: result.id,
           testId: test.id,
           projectId: test.projectId,
           testRunId: test.runId,
           screenShotId: result.screenShotId,
           log: result.log,
           type: result.resultType,
           runTime: result.runTime,
           status: result.status,
           startDate: result.startDate,
           endDate: result.endDate,
           errorMessage: result.errorMessage,
           failedStep: result.failedStep
       })
        @results_service.record_test_results jre
      end
    end
  end

end
