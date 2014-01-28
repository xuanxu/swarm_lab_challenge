#!/usr/bin/env ruby
# Ruby version of the "R vs Python Challenge" - Round 2
# http://www.theswarmlab.com/r-vs-python-round-2/

require 'nokogiri'
require 'open-uri'
require 'csv'

# Generate a list of all letters for the Movie pages (+ a "numbers" page)
# MovieBodyCount's actor pages are all with capital letters EXCEPT v and x
page_list = ["numbers"] + ("A".."Z").to_a.map! { |x| ["V", "X"].include?(x) ? x.downcase : x }
page_list = page_list.map {|page| "movies-" + page + ".htm"}
movie_links = []

page_list.each do |page|
  begin
    html = Nokogiri::HTML(open("http://www.moviebodycounts.com/" + page ))
    movie_links += html.xpath("//img[@src='graphic-movies.jpg']/following::a/@href").map{|l| l.text}
  rescue (OpenURI::HTTPError)
  end
end

# Remove duplicate, invalid and empty links
movie_links = (movie_links - page_list).uniq.compact

movies_data = []
movie_links.each do |movie_page|
  begin
    # Some links are relative some are absolute
    link = movie_page.downcase.start_with?("http") ? movie_page : "http://www.moviebodycounts.com/#{movie_page}"
    movie_html = Nokogiri::HTML(open(link))

    # Kill count is contained in the first non-empty text node after the image which source file
    # is called "graphic-bc.jpg". Except in a few cases where it is in the second node.
    kill_count_nodes = movie_html.xpath("//img[@src='graphic-bc.jpg']/following::text()[normalize-space()]")

    movies_data << {
      title: movie_html.xpath("//title").text.gsub("Movie Body Counts: ", ""),
      year:  movie_html.xpath("//a[contains(@href, 'charts-year')]/descendant::text()").text.to_i,
      imdb:  movie_html.xpath("//a/@href[contains(.,'imdb')]").first.text,
      kill_count: (kill_count_nodes[0].text.match(/\d+/) ? kill_count_nodes[0].text.match(/\d+/)[0] : kill_count_nodes[1].text.match(/\d+/)[0]).to_i
    }
  rescue (OpenURI::HTTPError)
  end
end

# Write data to a csv file
CSV.open("movies.csv", "w") do |csv|
  csv << ["Title", "Year", "IMDB", "Kills"] # Headers
  movies_data.each do |movie|
    csv << [movie[:title], movie[:year], movie[:imdb], movie[:kill_count]]
  end
end
