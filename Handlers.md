#Handlers

Handlers are the customizable portion of this gem without having dive deep into the source code. They are responsible for handling the events that are emitted by the systems event emitter.

###How it works

The system for getting real-time feed back is designed loosely on the *Observer Pattern*. As such, the system is two main objects, an `EventEmitter` and an `EventHandler`.
 
####EventEmitter

The `EventEmitter` will fire off an event an different points in the life cycle of a test run. These events will be sent to (or called against) any `EventHandler` object that has been registered with the `EventEmitter`.  It is then the responsibility of the `EventHandler` to process those events. Each time one of these events is fired, it will pass alone either an `Object` reference or a `String` depending on the event. The events that will be fired (as well as what type of parameter will be passed to them) are as follows (and not in any particular order):
- start_test_run - `DATSauce::TestRun`
- stop_test_run - `DATSauce::TestRun`
- start_rerun - `DATSauce::TestRun`
- test_run_completed - `DATSauce::TestRun`
- test_created - `DATSauce::Test`
- start_test - `DATSauce::Test`
- stop_test - `DATSauce::Test`
- test_completed - `DATSauce::Test`
- info - `String`
    
 It is up to you to decide what you want to do with the information provided by these `Objects`. And that's where implementing your own handler comes in.


####EventHandler and implementing your own

The `EventHandler` is fairly straight forward. The parent class has only 4 methods, `DATSauce::EventHandler.event_handlers` `stdout?` `stdout=()` and `process_event()`.  The first being a class method to get back a `Hash` of the build in event handlers. This is used `EventHandlerRegister` for registering even handlers.
`stdout?` and `stdout=()` are getters and setters (respectively) for the `@stdout` property that is used to determine whether or not the `EventHandler` uses `$stdout`.  If this is not explicitly set by the child classes constructor, it will default to false.
The most important method on the `EventHandler` class is the `process_event()` method.  It is responsible for sending the events to each `EventHandler` and is what is called by the `EventEmitter` for each fired event.  It is designed in such a way that each child class of the `EventHandler` parent class can have one or none of the events implemented. It simply ignores events not implemented. This is nice because you only need to implement the events you are interested in.

To start implementing your own `EventHandler`, you will first need to create the proper directory to store your custom handler in. Because dat_sauce is designed as a Cucumber test runner, I figured the best place to store these would be in the `./features/support` folder. In that folder, you will need to create a new folder name **handlers**.
Next, you will need to create a new rb file with the underscore version of your event handlers class name as the file name.  For example:

If I wanted my class to be defined like this:
```
    class CustomHandler
        ...
    end
        
```

My file name would need to be *custom_handler.rb*

This is necessary for making sure that the source code for your custom handler is loaded correctly by the dat_sauce gem.

Next, you will need to define your CustomHandler class, inheriting from the base `DATSauce::EventHandler` class.  Here is what the above `CustomHandler` class would look like:
```ruby
require 'dat_sauce/event_handler'

class CustomHandler < DATSauce::EventHandler

  def initialize
    @stdout = true
  end
  
  def info(value)
    puts value
  end

end
```

As shown above, you will also need to reference the `DATSauce::EventHandler` source code with a require at the top of you class definition `require 'dat_sauce/event_handler'`
Like I mentioned before, the great thing about this design is that you can implement handling for all of the events, just one event, or none at all (if you really wanted to).  In the above example, we see that only the `info` event has been implemented.  When that event is fired, our implementation take the `value` passed in and `puts` it to the console.

One thing to note here, the use of `$stdout` and setting the `@stdout` property is not a steadfast rule. More like a suggestion. You can easily bypass that restriction by setting your custom handlers `@stdout` property to `false` and it will work just fine.  The idea behind that loose restriction, is to keep the console output clean. Multiple handlers that use the console to print information back to the user can get messy.

With the above implementation, when any of the other events are fired, they will simply be dropped on floor and ignored. And that's. This is all about you and how you want to (or not want to) handle the events.
  
Continuing with the above example, lets say that we wanted to let output information about the test run at the start of the test.  To do that, we would need to provide and implementation for the `start_test_run()` event. In this example, I want to output how many tests are going to be executed this run.  Lets see how that looks:
```ruby
require 'dat_sauce/event_handler'

class CustomHandler < DATSauce::EventHandler

  def initialize
    @stdout=true
  end
  
  def info(value)
    puts value
  end
  
  def start_test_run(test_run)
    puts test_run.test_count
  end

end
```

When we look up our list of events and the objects that are passed with those events, we see that we are given a `DATSauce::TestRun` object.  That object has a property on it called `@test_count` that can be accessed with a getter `test_count`. Once we have that value, we display in the console with `puts`.  Now, every time the `start_test_run` event is fired, your handler will report the number of tests to be run.

A full list of properties and available methods for both the `DATSauce::TestRun` and `DATSauce::Test` objects can be found in the yard documentation [here](./doc/_index.html)

####Using your CustomHandler

To specify the use of our newly created `CustomHandler`, we simply need to pass the camel_case class name into the `DATSauce.run_tests(params)` as part of your `params`. Lets take a look at what that would look like in code:
```ruby
    params = {
        :project_name => 'Apollo',
        :run_options => ["-p prod", "DRIVER=selenium"],
        :test_directory=> './features',
        :outputs => ['CustomHandler'],
        :run_location => {:location => 'local'},
        :number_of_processes => 10
    }
    
    DATSauce.run_tests(params)
```

Here we can see that the value of `:outputs` is now set to our new `CustomHandler` class.

And there you have it, our first custom handler. Where you go from here, it up your imagination. 