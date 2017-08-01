# frozen_string_literal: true

$stdout.sync = true

require 'bundler'
ENV['RACK_ENV'] ||= 'development'

Bundler.require :default, ENV['RACK_ENV'].to_sym

Dotenv.load if %w[development test].include?(ENV['RACK_ENV'])

require File.expand_path(File.dirname(__FILE__) + '/app')

run YoutubeIntegration
