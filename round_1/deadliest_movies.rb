require 'csv'
require 'open-uri'
require 'gruff'

body_count_data = CSV.read(open("http://files.figshare.com/1332945/film_death_counts.csv"), headers:  true)

body_count_data.map do |row|
  row << {"Deaths_Per_Minute" => (row["Body_Count"].to_i / row["Length_Minutes"].to_f),
          "Full_Title" => "#{row['Film']} (#{row['Year']})"}
end

body_count_data = body_count_data.sort_by {|row| -row["Deaths_Per_Minute"]}.shift(25)

g = Gruff::SideBar.new(1800)

g.title = "25 most violence packed films by deaths per minute"

labels = []
body_count_data.each do |data|
    g.data("#{data["Full_Title"]} - #{data['Length_Minutes']} mins", data['Deaths_Per_Minute'] )
    labels << data["Full_Title"]
end

g.labels = (0..(labels.size-1)).to_a.inject({}) {|list, index| {index => labels[index]}.merge(list)}

g.show_labels_for_bar_values = true
g.use_data_label = true
g.hide_legend = true
g.hide_line_numbers = true

g.top_margin    = 10
g.left_margin   = 10
g.right_margin  = 10
g.bottom_margin = 10

g.marker_font_size = 12
g.title_font_size = 18

g.theme = {
   :colors => ['#8A0606'],
   :marker_color => 'white',
   :marker_shadow_color => 'white',
   :font_color => 'black',
   :background_colors => 'white'
   #:background_image => open("http://www.theswarmlab.com/wp-content/uploads/2014/01/bloody_gun.jpg").path
}

g.minimum_value = 0
g.maximum_value = 6

g.write("graphgun.png")
