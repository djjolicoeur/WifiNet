#!/usr/bin/env ruby

require 'rubygems'


  
class WifiNet
  attr_accessor :essid, :quality, :key

  def initialize(iface)
    system("ifconfig #{iface} up")
    essidStack = []
    qualityStack = []
    keyStack = []
    p = IO.popen("iwlist #{iface} scanning")
    data = p.readlines
    data.each do |d|
      string = d
      split = d.split(":")
      if split[0].strip.downcase.include?("essid")
        essidStack.push(split[1].strip)
      else if  split[0].strip.downcase.include?("quality")
        qualityStack.push(split[1].strip)
      else if split[0].strip.capitalize.include?("key")
        keyStack.push(split[1].strip)
      end
    end
		
		q = 0
		while essidStack.size() != 0
			e = essidStack.pop
			rawQual = qualityStack.pop
			k = keyStack.pop

			split = rawQual.split("/")
			
			newQ = split[0].to_i / split[1].to_i
			
			if newQ > q and key.downcase == "off"
				q = newQ
				@essid = e
				@key = k
				@quality = q
			end





  



    
  end

  def connect()
    
end


net = WifiNet.new("test", "64/76","off")

puts net.essid
puts net.quality
puts net.key


