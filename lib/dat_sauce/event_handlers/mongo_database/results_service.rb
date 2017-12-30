# TODO: Future home for the RESTful JSON API calls for writing results to the database
require 'net/http'
require 'json'
require 'pry'

class ResultsService

  #TODO - may add parameter for headers later
  def initialize(address, port)
    @address = address.nil? ? 'localhost' : address
    @port = port.nil? ? 3002 : port
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
    res = Net::HTTP.new(@address, @port).patch("/api/tests/#{test.id}", test.to_json, @headers)
    if res.code == '201'
      true
    else
      false
    end
  end

  def record_test_results(test_result_json)
    res = Net::HTTP.new(@address, @port).post('/api/testResults', test_result_json, @headers)
    if res.code == '201'
      true
    else
      false
    end
  end

  def record_test_run_results(test_run_result)
    res = Net::HTTP.new(@address, @port).post('/api/testRunResults', test_run_result, @headers)
    if res.code == '201'
      true
    else
      false
    end
  end

  def update_last_run_on_test(test)
    res = Net::HTTP.new(@address, @port).patch("/api/tests/#{test.id}", test.to_json, @headers)
    if res.code == '201'
      true
    else
      false
    end

  end

  def add_test_run(test_run)
    res = Net::HTTP.new(@address, @port).post('/api/testRuns', test_run, @headers)
    if res.code == '201' || res.code == '300'
      true
    else
      false
    end
  end

  def update_test_run(test_run)
    res = Net::HTTP.new(@address, @port).patch("/api/testRuns/#{test_run[:id]}", JSON.generate(test_run), @headers)
    if res.code == '201'
      true
    else
      false
    end
  end





end