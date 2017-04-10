require_relative 'progress_bar_v2'

class ProgressBarEventHandler < DATSauce::EventHandler

  def initialize
    self.stdout = true
  end

  def start_test_run(test_run)
    @progress_bar = DATSauce::ProgressBar.new({:count => test_run.testCount})
    @progress_bar.start_progress
    @progress_bar.start_timer
  end

  def stop_test_run(test_run)

  end

  def test_run_completed(test_run)
    @progress_bar.finish
    report_results test_run
    #TODO: may do something with the test object here.
  end

  def test_completed(test)
    @progress_bar.increment 1

    if test.results[:rerun].nil?
      if test.results[:primary].status == 'passed'
        @progress_bar.pass_count += 1
      elsif test.results[:primary].status == 'failed'
        @progress_bar.fail_count += 1
        @progress_bar.current_failures << test.results[:primary].scenarioPath
      end
    else
      if test.results[:rerun].status == 'passed'
        @progress_bar.pass_count += 1
      elsif test.results[:rerun].status == 'failed'
        @progress_bar.fail_count += 1
        @progress_bar.current_failures << test.results[:rerun].scenarioPath
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