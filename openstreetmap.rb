#!/bin/ruby

require 'rubygems'
require 'httparty'

class FeatureCollection
  include HTTParty
  format :json

end
  
