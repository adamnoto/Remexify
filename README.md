# Remexify

Remexify is a simple, opinionated ruby gem to log info/error/warning to your database. It only works
with database. This gem only work with Rails 3/4.

## Behind the scene

In all the projects I am working on, I always have a database-backed logger. I am tired of managing
all of those, but should-be identical logger. So, this gem really helped in.

## Installation

Add this line to your application's Gemfile:

    gem 'remexify'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remexify

## Usage

This gem monkey patch two error classes:
 1. RuntimeError
 2. StandardError
 
with a function called already_logged. already_logged? will return nil if the exception is not yet logged.
Additionally, there is new error class DisplayableError. DisplayableError will be quite handy if you
only want to let specific error to be displayed, thus, raise it with DisplayableError. DisplayableError
is nothing but a StandardError subclassed.

Well, to use this gem, you do need to generate some files. You can let the gem to generate all the required
files including migrations and initializers for you. To do so, issue:
    rails g remexify System::Loggers
    
You can name your log class anything, in the above example the log class is named System::Loggers. After that,
you have to migrate it.
    rake db:migrate
    
Finally, you can use the gem!
    Remexify.log err
    Remexify.info "System is starting"
    
Remexify have 3 static functions:
    def write(level, obj, options = {}); end;
    def info(obj, options = {}); end;
    def warning(obj, options = {}); end;
    def error(obj, options = {}); end;
    
write() is the most basic function, that you will only need to use if you want to define the level yourself.
Some level is predefined:

    INFO = 100
    WARNING = 200
    ERROR = 300

Thus, if you call info() basically you will have 100 as your level.

The obj can be any object. You can pass it a(n instance of) String, or an Exception, StandardError, RuntimeError, DisplayableError.
It will automatically generate the backtrace if the object passed is an exception.

Options can have:
    1. :method
    2. :line
    3. :file
    4. :parameters
    5. :description

All those options are optional, and, if given, will be stored in the database.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/remexify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
