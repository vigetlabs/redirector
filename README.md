# Redirector

Redirector is a Rails engine that adds a piece of middleware to the top of your middleware stack that looks for redirect rules stored in your database and redirects you accordingly.

## Install

1. Add this to your Gemfile and then `bundle install`:
  <pre><code>gem 'redirector'</code></pre>
2. `$ rake redirector_engine:install:migrations`
3. `$ rake db:migrate`
4. Create an interface for admins to manage the redirect rules.


### Config option

There is one config option `include_query_in_source`. If you want your redirect rules to also match against the query string as well as the path then you need to set this to `true` (the default is `false`). You can set this inside your configuration in `config/application.rb` of your Rails application like so:

    module MyApplication
      class Application < Rails::Application
        # ...
        
        config.redirector.include_query_in_source = true
      end
    end

## Redirect Rule definitions

Redirect rules have 3 parts:

1. A Source
2. A Destination
3. Request environment conditions

The source defines how to match the incoming request path and the destination is where to send the visitor if the match is made. A source can be a strict string equality match or it can be a regular expression that is matched. If a regular expression is used and it uses groupings, you can reference those groupings inside of the destination. For instance a regex like `/my_custom_path\/([0-9]+)/` could use that grouping in the destination like this `"/my_destination/$1"`. So, if the request path was `"/my_custom_path/10"` then the destination for that rule would be `"/my_destination/10"`.

Redirect rules can also have further Rack/HTTP environment (mainly HTTP headers) conditions via RequestEnvironmentRules. These define a key in the rack environment passed into the middleware and a value match you require for the redirect rule it's tied too. Similar to the redirect rules these RequestEnvironmentRules can be string matches or regex matches. A redirect rule can have as many of these environment rules as you need.

When using regex matching on either a redirect rule source or a request environment rule environment value you can specify if you want the matching to be case sensitive or case insensitive with a boolean column that's on the table.

### Schema Definition

Here's the schema definition used for the two tables:

    create_table "redirect_rules", :force => true do |t|
      t.string   "source",                                      :null => false # Matched against the request path
      t.boolean  "source_is_regex",          :default => false, :null => false # Is the source a regular expression or not
      t.boolean  "source_is_case_sensitive", :default => false, :null => false # Is the source regex cas sensitive or not
      t.string   "destination",                                 :null => false
      t.boolean  "active",                   :default => false                 # Should this rule be applied or not
      t.datetime "created_at",                                  :null => false
      t.datetime "updated_at",                                  :null => false
    end
    
    create_table "request_environment_rules", :force => true do |t|
      t.integer  "redirect_rule_id",                                       :null => false
      t.string   "environment_key_name",                                   :null => false # Name of the enviornment key (e.g. "QUERY_STRING", "HTTP_HOST")
      t.string   "environment_value",                                      :null => false # What to match the value of the specified environment attribute against
      t.boolean  "environment_value_is_regex",          :default => false, :null => false # Is the value match a regex or not
      t.boolean  "environment_value_is_case_sensitive", :default => true,  :null => false # is the value regex case sensitive or not
      t.datetime "created_at",                                             :null => false
      t.datetime "updated_at",                                             :null => false
    end

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
