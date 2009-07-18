has-bit-field
=============

has-bit-field allows you to use one attribute of an object to store a bit field which stores the boolean state for multiple flags.

To use this with Active Record, you would first require this gem in `config/environment.rb`:

    config.gem "pjb3-has-bit-field", :lib => "has-bit-field", :source => "http://gems.github.com"

Now in one of your models, you define a bit field like this:

    class Person < ActiveRecord::Base
      has_bit_field :bit_field, :likes_ice_cream, :plays_golf, :watches_tv, :reads_books
    end

This means that your database will have an integer column called `bit_field` which will hold the actual bit field.  This will generate getter and setter methods for each of the fields.  You can use it like this:

    $ script/console 
    Loading development environment (Rails 2.3.2)
    p =>> p = Person.new
    => #<Person id: nil, bit_field: nil, created_at: nil, updated_at: nil>
    >> p.likes_ice_cream = "true"
    => "true"
    >> p.plays_golf = 1
    => 1
    >> p.save
    => true
    >> p = Person.find(p.id)
    => #<Person id: 1, bit_field: 3, created_at: "2009-07-18 03:04:06", updated_at: "2009-07-18 03:04:06">
    >> p.likes_ice_cream?
    => true
    >> p.reads_books?
    => false


Copyright
---------

Copyright (c) 2009 Paul Barry. See LICENSE for details.
