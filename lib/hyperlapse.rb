require 'core_extensions/float/trigonometry'
require 'hyperlapse/app_config'
require 'hyperlapse/path_config'
require 'hyperlapse/config'
require 'hyperlapse/cli'
require 'hyperlapse/parser'
require 'hyperlapse/downloader'
require 'hyperlapse/generator'
require 'hyperlapse/cleanser'
require 'hyperlapse/version'

module Hyperlapse
  CLI.start(ARGV)
end
