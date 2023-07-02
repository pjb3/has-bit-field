require 'rubygems'
require 'bundler'
Bundler.setup

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'test/unit'
require 'active_record'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'has-bit-field'))
ActiveRecord::Base.extend HasBitField

#ActiveRecord::Base.logger = Logger.new($stdout)
