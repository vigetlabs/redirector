# Redirector

Redirector is a Rails engine that adds a piece of middleware to the top of your middleware stack that looks for redirect rules stored in your database and redirects you accordingly.

## Install

1. Add this to your Gemfile

      gem 'redirector'

2. `$ rake redirector:install:migrations`
3. `$ rake db:migrate`
4. Create an interface for admins to manage the redirect rules.


## Redirect Rule definitions

TODO

## Databases supported

* MySQL
* PostgreSQL

If you require support for another database, the only thing that needs to be added is a definition for a SQL regular expression conditional (see `app/models/redirect_rule.rb`). If you create a pull request that adds support for another database, it will most likely be merged in.

## Contributing to Redirector
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Brian Landau (Viget). See MIT_LICENSE for further details.
