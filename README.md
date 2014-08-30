# Remexify

Remexify is a simple, opinionated Ruby on Rails gem to write logs to your database. No fluff and to the point,
record and access your logs anytime from your database.

## Behind the scene

> Roses are red violets are blue, a log is not a poem it should be accessible to you.

In all the projects I am working on, I always have a database-backed logger. I am tired of managing
all of those, but should-be identical logger. So, this gem really helped in.

## Installation

Add this line to your application's Gemfile:

    gem 'remexify'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remexify

## Design Decision

This gem monkey patch attribute already_logged(?) in two standard ruby error classes:

1. RuntimeError
2. StandardError
 
`already_logged` (or `already_logged?`) will return nil if the exception is not yet logged.

Additionally, there is new error class `DisplayableError`. DisplayableError will be quite handy if you want to raise an enduser-visible error. In your controller, you may only allow an instance of DisplayableError to be displayed. DisplayableError
is nothing but a StandardError subclassed.

If Remexify caught exceptions any of the above class, it will mark `already_logged` to `true`. Remexify won't log it again when parent/calling method rescue the error.

## Usage

To use this gem, you need to generate some files first. You can let the gem to generate all required files, including migration and initializer, for you. To do so, issue:

    rails g remexify System::Loggers
    
You can name your log class anything, such as `System::Loggers`. After that, you have to migrate it.

    rake db:migrate
    
Finally, you can use the gem!

    Remexify.log err
    Remexify.info "System is starting"
    
In a rails app, you may invoke the `error()` like this:

    begin 
      raise "error"
    rescue => e 
      Remexify.error e, file: __FILE__, class: self.class.name, method: __method__, line: __LINE__
      raise e
    end 
            
Remexify have 4 static functions:

    def write(level, obj, options = {}); end;
    def info(obj, options = {}); end;
    def warning(obj, options = {}); end;
    def error(obj, options = {}); end;
    
`write()` is the most basic function, that you will only need to use if you want to define the level yourself.
Some level is predefined:

    INFO = 100
    WARNING = 200
    ERROR = 300

Thus, if you invoke `info()` level will be 100.

The obj can be any object. You can pass it a(n instance of) `String`, or an `Exception`, `StandardError`, `RuntimeError`, `DisplayableError`.

It will **automatically generate the backtrace if the object passed is an exception.**

Options can have:

1. :method
2. :line
3. :file
4. :parameters
5. :description

All those options are optional, and, if given, will be stored in the database.

In order to retrieve the recorded logs, you will deal with Remexify's Retrieve module. You may retrieve all logs:

    Remexify::Retrieve.all
    
Or, you may also retrieve all logs recorded today:

    Remexify::Retrieve.today
    
Both methods accepts a hash to which you can indicate an ordering of retrieved data:

    Remexify::Retrieve.all order: "created_at DESC"
    
You may also delete all the logs in your database:

    Remexify.delete_all_logs

## What is recorded?

These are the fields that is recorded:

Field name | Key | Is for...
---------- | ------------- | ------------
level | N/A | let you know the level of the log: error, warning or info.
md5 | N/A  | the fingerprint of the error, similar error should have similar fingerprint.
message | :message | string of the error
backtrace | N/A | backtrace of error, if the object is an instance of Error
file_name | :file | file where the log was recorded
class_name | :class | class where the log was recorded
method_name | :method | method where the log was recorded
line | :line | line where the log was recorded
parameters | :params | arguments that's passed in a function/block that can be used later in attemp to reproduce the error
description | :desc | programmer may pass in additional description here
frequency | N/A | how many times `Remexify` encounter this error?
timestamps | N/A | timestamp of the error when it was created, and last updated.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/remexify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

by Adam Pahlevi Baihaqi