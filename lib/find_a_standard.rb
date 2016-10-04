$:.unshift File.dirname(__FILE__)

require 'dotenv'
Dotenv.load

require 'elasticsearch'
require 'open-uri'
require 'oga'
require 'sinatra'
require 'sinatra/respond_to'
require 'csv'

require 'find_a_standard/client'
require 'find_a_standard/index'
require 'find_a_standard/results_presenter'
require 'find_a_standard/app'

module FindAStandard

end
