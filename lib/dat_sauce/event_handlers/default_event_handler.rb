require_relative 'event_handler'


class DefaultEventHandler < DATSauce::EventHandler

  # event fired when a test run is started
  # @param test_run DATSauce::TestRun
  def start_test_run(test_run)
    puts "RunId: #{test_run.runId}\nProject: #{test_run.projectName}\nTest Count: #{test_run.testCount}\nQueue Size: #{test_run.queueSize}\nRunOptions: #{test_run.runOptions}\nStatus: #{test_run.status}\n"
  end

  # event fired when a test run is stopped
  # @param test_run DATSauce::TestRun
  def stop_test_run(test_run)

  end

  # event fired when a rerun is started
  # @param test_run DATSauce::TestRun
  def start_rerun(test_run)

  end

  # event fired when a test run is completed
  # @param test_run DATSauce::TestRun
  def test_run_completed(test_run)
    report_results test_run
  end

  # event fired when a test object is created
  # @param test DATSauce::Test
  def test_created(test)

  end

  # event fired when a test is started
  # @param test DATSauce::Test
  def start_test(test)
    puts "\e[36mRunning test:\e[0m \e[37m#{test.name} Line: #{test.lineNumber}\e[0m"
  end

  # event fired when a test is stopped
  # @param test DATSauce::Test
  def stop_test(test)

  end

  # event fired when a test is completed
  # @param test DATSauce::Test
  def test_completed(test)
    case test.status
      when 'passed'
        puts "\e[34mTest:\e[0m \e[37m#{test.name} Line: #{test.lineNumber}\e[0m Status: \e[92mPassed\e[0m"
      when 'failed'
        puts "\e[34mTest:\e[0m \e[37m#{test.name} Line: #{test.lineNumber}\e[0m Status: \e[31mFailed\e[0m"
      when 'undefined'
        puts "\e[34mTest:\e[0m \e[37m#{test.name} Line: #{test.lineNumber}\e[0m Status: \e[93mUndefined\e[0m"
      when 'pending'
        puts "\e[34mTest:\e[0m \e[37m#{test.name} Line: #{test.lineNumber}\e[0m Status: \e[96mPending\e[0m"
    end
  end

  # event fired when and info event is fired
  # this is usually status information. Things like telling the user all threads are full and sending remaining tests to a queu
  # @param message String
  def info(message)
    puts "\e[35m#{message}\e[0m"
  end

  private

  def report_results(test_run)
    @results = test_run.results
    puts '#############################'
    puts 'Primary run results'
    puts "Total Number of Scenarios ran: #{@results[:primary].scenarios.length}"
    puts "\e[32mPassed: #{@results[:primary].passCount} \e[91mFailed: #{@results[:primary].failCount} \e[96mPending: #{@results[:primary].pendingCount} \e[93mUndefined: #{@results[:primary].undefinedCount}"
    unless @results[:primary].failedScenarios.empty?
      puts "Failed Scenarios:\n"
      print_failures(@results[:primary].scenarios)
    end
    puts "Took #{calculate_runtime(@results[:primary].runTime)}"
    puts '#############################'
    unless @results[:rerun].nil?
      puts 'Rerun results'
      puts "Total Number of Scenarios ran: #{@results[:rerun].scenarios.length}"
      puts "\e[32mPassed: #{@results[:rerun].passCount} \e[91mFailed: #{@results[:rerun].failCount} \e[96mPending: #{@results[:rerun].pendingCount} \e[93mUndefined: #{@results[:rerun].undefinedCount}"
      unless @results[:rerun].failedScenarios.empty?
        puts "Failed Scenarios:\n"
        print_failures(@results[:rerun].scenarios)
      end
      puts "Took \e[94m#{calculate_runtime(@results[:rerun].runTime)}\e[0m"
      puts '#############################'
    end
    puts "Total Runtime: \e[94m#{calculate_runtime(@results[:runTime])}\e[0m"
  end



  def calculate_runtime(time)
    Time.at(time).utc.strftime("%H:%M:%S")
    # [total_time / 3600, total_time/ 60 % 60, total_time % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')
  end

  def print_failures(scenarios)
    scenarios.each do |scenario|
      if scenario[:status] == 'failed'
        puts "\e[37m#{scenario[:scenarioPath]}\e[0m"
        puts "\e[31m#{scenario[:errorMessage]}\e[0m"
      end
    end
  end


end