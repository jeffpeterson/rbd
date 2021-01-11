# frozen_string_literal: true

require "optparse"
require "ostruct"

module Rbd
  class NoMainError < StandardError; end

  class Cli
    attr_reader :cmd, :flags, :args

    def initialize
      @flags = OpenStruct.new
      @args = ARGV.clone
      opt_parser.parse!(@args, into: flags)
      @cmd = @args.shift || "run"
    end

    def run!
      return puts "Todo: help" if flags.help

      case cmd
      when "run"

        raise Rbd::NoMainError unless load! "main", "lib/main"
      else
        puts "Not a valid command: #{cmd}"
      end
    rescue Rbd::NoMainError
      puts "Could not run project. Expected main.rb file"
    end

    def opt_parser
      @opt_parser ||= OptionParser.new do |op|
        op.on("-h", "--help", "Displays help")
      end
    end

    def load!(*files)
      file, *files = files
      return if file.nil?

      load "#{Dir.pwd}/#{file}.rb"
      file
    rescue LoadError
      load!(*files)
    end
  end
end
