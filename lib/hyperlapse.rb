# require 'hyperlapse/version'
# FIXME
require './lib/core_extensions/float/trigonometry'
require './lib/hyperlapse/app_config'
require './lib/hyperlapse/cli'
require './lib/hyperlapse/downloader'
require './lib/hyperlapse/generator'
require './lib/hyperlapse/parser'
require './lib/hyperlapse/path_config'

module Hyperlapse
  Float.include CoreExtensions::Float::Trigonometry
  CLI.start(ARGV)
end
