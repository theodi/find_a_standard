require 'rubygems'
require 'bundler'
Bundler.setup

ENV['RACK_ENV'] ||= 'development'

require File.join(File.dirname(__FILE__), 'lib/find_a_standard.rb')

run FindAStandard::App
