# require 'hyperlapse/version'
# FIXME
require './lib/core_extensions/float/trigonometry'
require './lib/hyperlapse/app_config'
require './lib/hyperlapse/path_config'
require './lib/hyperlapse/config'
require './lib/hyperlapse/cli'
require './lib/hyperlapse/parser'
require './lib/hyperlapse/downloader'
require './lib/hyperlapse/generator'
require './lib/hyperlapse/cleanser'

module Hyperlapse
  CLI.start(ARGV)
end
