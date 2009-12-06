#!/bin/ruby

require 'rubygems'
require 'httparty'

class Geocoder
  include HTTParty
  format :json

  def Geocoder.find_location(key, location)
    return Geocoder.get("http://geocoding.cloudmade.com/#{KEY}/geocoding/v2/find.js?query=#{location}&return_location=false&return_geometry=false")
  end
end

KEY='e303e08e8419448b90b8618ecd605791'
url="http://geocoding.cloudmade.com/#{KEY}/geocoding/v2/find.js?query=Fleet+street,+London,+UK&return_location=false&return_geometry=false"
puts url
#puts Geocoder.get(url).inspect

g = Geocoder.find_location(KEY, "Fleet+street,+London,+UK")
puts g.inspect

puts g["features"].inspect
puts g["features"][0]["centroid"].inspect

def sec(x)
  return (1 / Math.cos(x))
end

def rad(x)
  return x * (Math::PI/180)
end

zoom=10
lon_deg = g["features"][0]["centroid"]["coordinates"][0]
lat = g["features"][0]["centroid"]["coordinates"][1]

puts "longitude #{lon_deg}"
puts "latitude #{lat}"

lat_rad=(lat/180) * Math::PI
#lng_rad=(lon/180) * Math::PI
n = 2 ^ zoom
xtile = ((lon_deg + 180) / 360) * n
ytile = (1 - (Math.log(Math.tan(lat_rad) + sec(lat_rad)) / Math::PI)) / 2 * n

puts n
puts xtile
puts ytile
puts "http://b.tile.cloudmade.com/#{KEY}/1/256/#{n}/#{xtile.floor}/#{ytile.floor}.png"

g = Geocoder.find_location(KEY, "inefioenofnwe")
puts g.inspect
