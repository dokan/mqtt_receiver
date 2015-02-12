#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "yaml"

require 'bundler'
Bundler.require

config = YAML.load_file('config.yml')

macaddr = Mac.addr
macaddr.gsub!(":", "").downcase!

p macaddr
MQTT::Client.connect(config["host"]) do |c|
  # If you pass a block to the get method, then it will loop
  c.get("/#{macaddr}/+") do |topic,message|
    puts "#{topic}: #{message}"
    target = nil
    if topic =~ /^\/#{macaddr}\/(.*)/
      target = $1
    end
    next if target.nil?
    begin
      @message_hash = JSON.parse!(message, {:symbolize_names => true})
    rescue
      puts "json parse error"
      next
    end

    case target
    when "servo"
      angle = @message_hash[:angle].to_i
      puts "angle:#{angle}"
      system("#{config["servo_command"]} #{angle}")
      puts $?
    when "led"
    end
  end
end
