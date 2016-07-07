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


###Implementing an EventHandler

To start implementing your own `EventHandler`, you will first need to create the proper directory to store your customer handler in. Because dat_sauce is designed as a Cucumber test runner, I figured the best place to store these would be in the `./features/support` folder. In that folder, you will need to create a new folder name **handlers**.
Next, you will need to create a new rb file with the underscore version of your event handlers class name as the file name.  For example:

If I wanted my class to be defined like this:
```
    class CustomHandler
        ...
    end
        
```

My file name would need to be *custom_handler.rb*

This is necessary for making sure that the source code for your custom handler is loaded correctly by the dat_sauce gem.