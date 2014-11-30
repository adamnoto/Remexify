# Remexify

Remexify is the world's simplest Rails-only ActiveRecord gem to write/retrieve logs written into your database's table. 
Its philosophy is not to be a dictator gem, so you have your control over what to log, the log level, and et cetera. 
Remexify is happy to be no fluff, and to-the-point!

## Behind the scene

> Roses are red violets are blue, a log is not a poem it should be accessible to you.

Remexify is always by my side whenever I need to log something into the database. I am tired of managing different logger,
or duplicatings codes accross multitude of projects I am working on only to have this kind of ability that I wanted.
Therefore, I refactor it and made it into a gem available to all projects a bundle away not only for mine, but also for yours. 
I wish it will help you somehow.

## Why should you use Remexify?

Remexify...

1. Help you log to your own database, by giving you the control and ease on when/where to do that.
2. Let you log not only an error, but also info, log, etc. Actually, "error" is just a numeric constant.
3. Gives you the flexible means of accessing your logged error.
4. Let you *censor* specific error classes which you don't want it to appear in the backtrace.
5. Let you define acceptable/unacceptable classes of error which you can use to control what instance of exception class you want to dismiss, or to keep.
6. Logs similar error once, but will record the frequency if similar error occurred again.
7. Can associate your logs to certain user, object, or anything.
7. Is free and open source for all the People of Earth.

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

## Basic Usage

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

Thus, if you want to write info log by invoking `info()` then the log will be recorded with level set to 100.

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

A rather complex query:

    Remexify::Retrieve.all(order: "level ASC", owned_by: "1", level: "=200")
    
You may also delete all the logs in your database:

    Remexify.delete_all_logs

## What is recorded in the database?

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

## Define what errors to keep and what to dismiss.

Sometimes, you don't want an error to be logged. In certain cases, an error is not supposed to be logged. In other cases,
a specific logic is applied to acceptable, harmless specific error rather than poluting the database. 

I afraid you think that I encourage the use of error for control statement. Not at all. Consider this given scenario:

> You are designing an API which will be executed by a thread in a time you cannot be sure when, in other words: asynchronously.
> In some point of time, you expect that your class can raise a harmless exception. This exception is indeed an error,
> but is merely to indicate to the user that they cannot do certain action. Therefore, the error raised will be noticeable
> but the parent class and in turn, by Remexify. You wish not to log this error, because you don't want your database 
> to be polluted with this kind of harmless, acceptable, normal error. Some error that not causing headcache, some error
> that is not a bug. But the one you cannot control, because it is asynchronous. You decided to log information about
> this error in a row in your database, that the un-asynchronous caller can check regularly to see if the row is indicated
> as erroneous. And then, the end user can be notified of their erroneous action.

So, how could you accomplish that? It's easy, use either:

1. `discarded_exceptions` to enlist explicitly class of exception you don't want to log.
2. `accepted_exceptions` to enlist those that Remexify will log.

If you want to log any error but specific exception, then during initialisation you define:

```ruby
Remexify.setup do |config|
  # other codes above
  config.discarded_exceptions = [
    ErrorToIgnore
  ]
end
```

However, if you want to command Remexify to log error only the one you have given it rights to, you do define:

```ruby
Remexify.setup do |config|
  config.accepted_exceptions = [
    String,
    SpecificError
  ]
end
```

As simply as that, however, be informed that `discarded_exceptions` takes precedence. So, if you define a class as being both
discarded and accepted, it will certainly be discarded. As simply as that, as always.

## Associate logs to user

Consider this scenario

> You have a logged in user. But, your user did something that trigger an exception. But, not only that you want to
> log the exception, you also want to associate the exception with the user triggering the error.

Remexify from version 1.2.0 have the ability to record the user that trigger the error. When you log an error,
you can specify who owned the exception through `owned_by` attribute:

```ruby
Remexify.error "Some serious error by user with id 1", owned_by: 1
```

The code above will log an error, and associate the error with user id 1. You can specify the ID as string, or as integer,
but in the database it will be converted to String.

In case you needed to log any other information regarding to the ownership, Remexify provides you with 3 additional 
attributes:

1. `owned_param1`
2. `owned_param2`
3. `owned_param3`

Imagine that not only you have user table, you also have admin, and company table which all of them have the ability
to log into the database. You have user with ID 1, and an admin with ID 1 stored in their respective table. When error
is triggered by the admin ID 1, Remexify record the error as you command. However, when you are to retrieve errors triggered
by the admin ID 1, you have difficulty because there's also an error recorded with ID 1 but he is not an admin. but a user. 
Obviously, storing mere ID may not help, you need to discriminate further.

Here is how you would remedy the problem:

```ruby
Remexify.error "A serious error", owned_by: admin.id, owned_param1: admin.class.name
```

So far so good, but how to retrieve errors by user?

As usual, we need to use `Remexify::Retrieve` whether you will retrieve `all()` or `today()` then you can specify further
certain variable such as the `level`, the `order` and so on. Then, to retrieve by the admin's ID:

```ruby
Remexify::Retrieve.all owned_by: admin.id
```

Or, when you want to retrieve all error triggered by an admin, assuming you log the class name as `owned_param1`:

```ruby
Remexify::Retrieve.all owned_param1: admin.class.name
```

You can as well combine both command:

```ruby
Remexify::Retrieve.all owned_by: admin.id, owned_param1: admin.class.name
```

A slightly complex error:

```ruby
Remexify::Retrieve.all owned_param1: admin.class.name, level: ">= 200"
```

## Upgrading

1. Upgrading from 1.0.0 or 1.1.0 to 1.2.0
  1. Delete your Remexify model (you may backup the table contents, if you still need it)
  2. Delete your Remexify model's migration
  3. Copy all the configuration you have for your Remexify.
  4. Delete your configuration file.
  5. `bundle install` the latest gem, and generate the models.
  6. Migrate the models.
  7. Reconfigure your Remexify configuration file (if you write custom configuration).
  8. Done.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/remexify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

by Adam Pahlevi Baihaqi

## History

- v.1.0.0 Initial version. Supporting PostgreSQL and Rails 3/4 to log info/error/warning/user-defined error level.
- [v.1.1.0](http://universitas-utara.herokuapp.com/post/34-rilis_remexify_1_1_0) 
  - User can configure `censor_strings`, which would delete trace if its string contains one of the censored string.
  - Adding the level options, which would allow retriever to retrieve `all`/`today` log of certain level.
  - Increased accuracy: Error that occurred more than one time that involve unprintable object that have memory address, will have its memory address stripped only to display the class information.
- [v.1.2.0](#)
  - User can configure `accepted_exceptions`
  - User can configure `discarded_exceptions`
  - Ability to associate log to specific user
  - Ability to retrieve logs that owned by certain identifier_id (like, user's id)