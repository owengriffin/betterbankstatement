#!/bin/ruby

require 'rubygems'
require 'httparty'

module OpenStreetMap
  KEY='e303e08e8419448b90b8618ecd605791'
  class Geocoder
    include HTTParty
    format :json
    
    def Geocoder.find_location(location)
      return Geocoder.get("http://geocoding.cloudmade.com/#{OpenStreetMap::KEY}/geocoding/v2/find.js?query=#{location}&return_location=false&return_geometry=false")
    end
  end
end
