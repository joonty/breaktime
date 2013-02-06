module Breaktime
  lib_dir = File.dirname(__FILE__) + File::SEPARATOR + 'breaktime'
  $:.unshift lib_dir

  require 'rubygems'
  require 'bundler/setup'
  require 'version'
  require 'main'

  Main do
    def run
      require 'schedule'
    end

    mode 'config' do
      def run() puts 'config!' end
    end

    mode 'dialog' do
      def run
        require 'dialog'
      end
    end

    mode 'now' do
      def run() puts 'now!' end
    end

  end

end
