$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'rspec'
require 'webmock/rspec'
require 'pry'

require 'support/config_helper'

require "maxwell"
