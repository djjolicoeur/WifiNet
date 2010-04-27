#!/usr/bin/env ruby

require 'rubygems'


  
class WifiNet
  attr_accessor :essid, :quality, :key, :iface
  

  def initialize(iface)
    @iface = iface
    t = system("ifconfig #{iface} up")
    if t == false
      puts "interface error: exiting"
      exit 
    end
    essidStack = []
    qualityStack = []
    keyStack = []
    p = IO.popen("iwlist #{iface} scanning")
    data = p.readlines  
    data.each do |d|
      string = d
      
      if string.include?(":")
        split = string.split(":")
      elsif string.include?("=")
        split = string.split("=")
      end




      if split != nil and split.size > 1 
        if split[0].strip.downcase.include?("essid")
          essidStack.push(split[1].strip)
        elsif  split[0].strip.downcase.include?("quality")
          qualityStack.push(split[1].strip)
        elsif split[0].strip.downcase.include?("key")
          keyStack.push(split[1].strip)
        end
      end
    end

    if essidStack.size < 1
      puts "No available unencrypted networks: exiting"
      exit
    end
        

    q = 0
    while essidStack.size() != 0
      e = essidStack.pop
      rawQual = qualityStack.pop
      k = keyStack.pop

      e = e.gsub('"', '')
      split = rawQual.split("/")
      split[1] = split[1][0..2]
      newQ = split[0].to_f / split[1].to_f
      
      if newQ > q and k.downcase == "off" and e != ""
        q = newQ
        @essid = e
        @key = k
        @quality = q
      end
    end

    if @essid == nil
      puts "no unsecured networks available. exiting."
      exit
    end
    
  end
        
  def connect()
    system("dhcpcd -k #{@iface}")
    system("iwconfig #{@iface} essid \"#{@essid}\" key #{@key}")
    system("dhcpcd #{@iface}")
  end
    

end    

if ARGV.size < 1
  puts "Usage ruby WifiNet.rb <interface>"
  exit
end

net = WifiNet.new(ARGV[0])

puts net.essid
puts net.quality
puts net.key

net.connect()


