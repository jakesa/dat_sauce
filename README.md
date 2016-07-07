# dat_sauce
A test runner for Cucumber that implements parallelization


###Links
- [Documentation](./doc/_index.html)

- [Handlers](./Handlers.md)


##Install
Currently, you will need to clone the repository and build the gem from source as this has not been published to ruby gems.
```ruby
    gem build dat_sauce.gemspec
    gem install dat_sauce-1.0.3.gem
```
*Note that the version number is going to be whatever version the gem is currently at*

##Use

```ruby
    require 'dat_sauce'
```

The gem has a single entry point, `DATSauce.run_tests(params={})`.
This method takes in a `Hash` of parameters to configure each run. They are as follows:

```ruby
  {
      :project_name => String, #name of the project
      :run_options => Array<String>, #an array of cucumber options
      :test_directory => String, #the location of the tests
      :rerun => String, #serial or parallel tells the application whether or not you want to do a rerun of the failures and if you want them to be run in serial or parallel
      :outputs => Array<String>, #tells the system how you want the progress and the results displayed to the user
      :run_location => Hash<String, Array<String>>, #{:location, :desired_caps}
      :number_of_processes => Integer, #the number of concurrent processes you want running tests. Performance will decrease the higher you go. Typically, 2 times the number of physical cores is the ceiling
  }
```

####:project_name `String`

The `:project_name` is designed to be used for results tracking when results are stored to a database. Currently, there is not handler that will process results
 to a database. You will have to implement one on your own should you want results to be stored (*more on handlers and custom handlers later*)

####:run_options `Array<String>`

The `:run_options` are the options that you would normally pass to Cucumber on the commandline.  For example:

```
    cucumber -p default -f pretty ./some/path/to/tests
```
The `-p default` and the `-f pretty` are the cucumber options that you would include as the `:run_options`. 

```
    {
        ...
        :run_options => ['-p default', '-f pretty'],
        ...
     }
```

####:test_directory `String`

The `:test_directory` is the relative or absolute path to the directory or `.feature` file that contains the tests you would like to run.
```
    :test_directory => './features'
    
    :test_directory => './features/login_and_session/login.feature'
        
```

####:rerun `String` (*optional*)

The dat_sauce gem has to ability to rerun any failures that were detected in the original run.  Because running multiple web browsers at once for
 tests can cause some erroneous failures, it is some times necessary to rerun them.  The `:rerun` option, lets you specify whether you want to run
 them in parallel or serial. Running them in parallel again introduces the chance that they could erroneously fail again while decreasing the run time.
 While serial will run the tests one at a time.  This will decrease the likelihood of an erroneous failure significantly, but will result in longer run times.
 This parameter is optional and can be omitted. If it is, dat_sauce will not preform a rerun.

####:outputs(*handlers*) `Array<String>` (*optional*...*kinda*)

The `:outputs` parameter tells the dat_sauce gem how you want to see your progress.  While you will see the aggregated results at the end of the run,
if you do not supply an output, you will get no real-time progress indicators.
 There are currently two build in outputs, `progress_bar` and `team_city`.

`progress_bar` is a informational progress bar implemented in [curses](https://github.com/ruby/curses). It will give you real-time progress on the test run.
 The data includes, pass/fail counters, runtime, current progress percentage and a list of current failures (just which scenarios failed, not why).

`team_city` is an output that was designed for the TeamCity build server. This will output text to the console that TeamCity can parse.  It's not perfect, but
it gets the job done.

The optional nature of this parameter is that if you pass in an empty array or omit it completely, you will get no updates at all until the run is finished.
 If you choose to omit it completely, you will get a warning message telling as much and direct you to check your parameters.  Because this is a warning, it will
 process the test run anyway.

Another caveat to the outputs; while multiple handlers/outputs can be specified and used, only one output that takes over `STDOUT` is allowed at any given time.
 You can learn more about that in the below mentioned documentation, but as it stands now, you cannot use both `progress_bar` and `team_city` at the same time.

The outputs (or handlers) are the front end of a larger system designed for capturing progress while a test run is in motion. To learn more about they work and how
 to create your own handlers, please check out the documentation [here](./Handlers.md)

####:run_location `Hash<String, Array<String>>`

The run_location parameter is designed to specify if the tests should be run locally or remotely (*like on a selenium grid or SauceLabs*). Currently, the only implemented
option is to run tests locally and as such, 'local' is the only accepted option. `:run_location => {:location => 'local'}`.
The second parameter listed in the hash for the `desired_capabilities` that selenium_grid and SauceLabs are designed to use. They are omitted for now and will be impleted with
the support for remote run locations.

####:number_of_processes `Int` (*optional*)

The `number_of_processes` parameter is the number of concurrent tests you want running at any given time. This can be as high as you want or as low as you want. However, be aware
that each system you run your tests from has a limit as to what it can handle with its available resources. On a current core i7 system with 16GB of RAM, you will hit a performance wall
at about 10-18 concurrent processes.  From there, performance will start to degrade and run times will start to increase.

If this option is omitted, the dat_sauce gem will default to 2x the number of logical cores on your system.

###Example

A coded example of all of this put together would look something like this:

``` ruby
    require "dat_sauce"
    
    params = {
        :project_name => 'Apollo',
        :run_options => ["-p prod", "DRIVER=selenium"],
        :test_directory=> './features',
        :outputs => ['progress_bar'],
        :run_location => {:location => 'local'},
        :number_of_processes => 10
    }
    
    DATSauce.run_tests(params)
```

Because there are no binaries as of yet for this project, you will have to run your tests with something like [rake](https://github.com/ruby/rake) or create a script with something similar to the above code it in.