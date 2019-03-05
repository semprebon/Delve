# Generate map for tiddlywiki
#
# See http://tobibeer.github.io/tb5/#Interactive%20SVG%20Image%20Map

puts "generating map"
require "csv"
require "nokogiri"
require "pry"
require "cgi"

RADIUS = 1.0
LINK_TEMPLATE = %Q[
  <a xlink:href="#%{bookmark}" class="point">
    <g>
      <circle cx="%{x}" cy="%{y}" r="#{RADIUS}" stroke-width="1px"/>
      <text x="%{x}" y="%{y}">%{title}</text>
    </g>
  </a>]
STYLE = %Q[
  <style>
    .point text {
      font-size: 5pt;
      font-family: "Gill Sans", sans-serif;
      color: black;
    }
    .point circle { stroke: Black; stroke-width: 0.3; fill: LIGHTGRAY; }
    .map a:hover rect {
      fill: #22aa22 !important;
    }
  </style>
]
BASE_SVG = %Q[
  <svg class="map">
    <style>
      .point text {
        font-size: 5pt;
        font-family: "Gill Sans", sans-serif;
        color: black;
      }
      .point circle { stroke: Black; stroke-width: 0.3; fill: LIGHTGRAY; }
      .map a:hover rect {
        fill: #22aa22 !important;
      }
    </style>
  </svg>
]

def add_location(node, x, y, title, content)
  link_xml = LINK_TEMPLATE % { x:x, y:y, title:title, bookmark: title }
  node.add_child(link_xml)
end

background_doc = Nokogiri::XML(open("crossroads.svg"))
box = background_doc.at_css("svg")["viewBox"].split(/\s/).map(&:to_f)

doc = Nokogiri::XML(BASE_SVG)
svg_node = doc.at_css("svg")
#svg_node["class"] = "map"
#svg_node.add_child(STYLE)
CSV.foreach("locations.csv", headers: true) do |row|
    add_location(svg_node, row["x"].to_f, box[3]-row["y"].to_f, row["title"], "test")
end
File.open("crossroads_map.svg", "w") { |f|
  doc.write_xml_to(f, encoding: 'UTF-8')
}
