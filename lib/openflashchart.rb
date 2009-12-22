# -*- coding: undecided -*-
require 'rubygems'
require 'json'

module OpenFlashChart
    # Return some Javascript which can be embedded within a HTML document which includes the OpenFlashChart
    def OpenFlashChart.js(name, data, width=650, height=500, filename='open-flash-chart.swf')
      "
function #{name}() { return '#{data}'; };
swfobject.embedSWF('#{filename}', '#{name}', '#{width}', '#{height}', '9.0.0', 'expressInstall.swf', {'get-data':'#{name}'});
      "
    end

    def OpenFlashChart.pie_chart
      chart = Hash.new
      chart["bg_colour"] = "#FFFFFF"
      chart["elements"] = []
      chart["x_axis"] = nil
      return chart
    end

    def OpenFlashChart.pie_element
      element = Hash.new
      element["type"] = "pie"
      element["alpha"] = 0.6
      element["start-angle"] = 35
      element["animate"] = { "type" => "fade" }
      element["tip"] = "£#val# of £#total#"
      element["values"] = []
      return element
    end
end

