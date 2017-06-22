require 'bundler'
Bundler.require
Dotenv.load
require './app'
require 'rubygems'

require File.expand_path(File.dirname(__FILE__) + '/app')

run YoutubeIntegration
