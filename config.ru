$stdout.sync = true

require 'bundler'
ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

if ['development', 'test'].include?(ENV['RACK_ENV'])
	Dotenv.load
end

require File.expand_path(File.dirname(__FILE__) + '/app')

run YoutubeIntegration
