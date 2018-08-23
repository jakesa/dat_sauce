# require_relative 'results_parser_2'
require_relative 'custom_accessor'
require_relative 'test_result_parser'
module DATSauce
  class TestResult
    extend CustomAccessor

    custom_attr_accessor :log, :resultsSummary, :startDate, :testRunId, :resultType, :status, :runTime, :scenarioPath, :errorMessage,
                         :failedStep, :id, :endDate, :testId, :screenShotId

    def initialize(results, start_date, run_id, result_type, end_date, test_id, screen_shot_id)
      @resultsSummary = DATSauce::ResultsParser::Cucumber::Test.parse_results results
      @log = JSON.generate results
      @testId = test_id
      @startDate = start_date
      @endDate = end_date
      @testRunId = run_id
      @id = run_id + "#{(Time.now.to_i/1000)+rand(10000)}"
      @resultType = result_type
      @status = @resultsSummary[:status]
      @runTime = @resultsSummary[:runTime]
      @scenarioPath = @resultsSummary[:scenarioPath]
      @screenShotId = screen_shot_id
      if @status == 'failed'
        @errorMessage = @resultsSummary[:errorMessage]
        @failedStep = @resultsSummary[:failedStep]
      end

    end

    def to_hash
      obj = {}
      TestResult.attrs.each do |attr|
        obj[attr] = send(attr)
      end
      obj
    end

    def to_json
      JSON.generate to_hash
    end

    def to_s(log = false)
      str = ''
      TestResult.attrs.each do |attr|
        str << "#{attr}: #{send(attr)}\n" unless attr == :log && !log
      end
      str
    end
  end

end