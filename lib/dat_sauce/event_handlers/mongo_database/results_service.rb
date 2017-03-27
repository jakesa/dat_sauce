# TODO: Future home for the RESTful JSON API calls for writing results to the database
require 'net/http'
require 'json'
require 'pry'

class ResultsService


  def initialize(address = 'localhost', port = 3002)
    @address = address
    @port = port
    @headers = {
        'Content-type' => 'application/json'
    }
  end

  def add_test(test)
#JS - I need a new instance of HTTP every time to avoid conflicts with parallelization
    res = Net::HTTP.new(@address, @port).post('/api/tests', test.to_json, @headers)
    if res.code == '201' || res.code == '300'
      true
    else
      false
    end
  end

  def update_test(test)
    res = Net::HTTP.new(@address, @port).put("/api/tests/#{test.testId}", test.to_json, @headers)
    if res.code == '200'
      true
    else
      false
    end
  end

  def add_run_to_test(test)
    res = Net::HTTP.new(@address, @port).put("/api/tests/#{test.testId}/run", test.to_json, @headers)
    if res.code == '201'
      true
    else
      false
    end
  end

  def add_test_run(test_run)
    res = Net::HTTP.new(@address, @port).post('/api/testRuns', test_run.to_json, @headers)
    if res.code == '201' || res.code == '300'
      true
    else
      false
    end
  end

  def update_test_run(test_run)
    res = Net::HTTP.new(@address, @port).put("/api/testRuns/#{test_run.runId}", test_run.to_json, @headers)
    if res.code == '200'
      true
    else
      false
    end
  end





end