
Given /^I have tests setup$/ do
  sleep 3
end

When /^I run the test$/ do
  sleep 2
end

Then /^I see the test pass$/ do
  sleep 1
  true
end

When /^I run a test that takes a while$/ do
  sleep 10
end

Then /^I see the test fail$/ do
  raise 'Test Failed'
end

Given /^I have my outline setup$/ do
  sleep 2
end

When /^I run test with name (.*)$/ do |name|
  sleep 2
  name
end

Given /^I have a pending step$/ do
  pending
end

When /^I try to run the test$/ do
  pending
end

Then /^I see that it didnt run$/ do
  pending
end
