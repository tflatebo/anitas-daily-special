require 'nokogiri'
require 'open-uri'
require 'sinatra'
require 'haml'
require 'date'
require 'digest/md5'

class LunchSpecial
  attr_accessor :title, :url, :text_content, :html_content, :image_uri

  def initialize
    @title = "Anita's Daily Lunch Special"
    @url = 'http://www.truetastes.com/anitas-cafe-lunch-catering/'
    @content = "I can't find their lunch special, maybe it's Whipped potatoes? Visit <a href='http://www.truetastes.com/anitas-cafe-lunch-catering/'>their site</a> if you see this message."
    @image_uri = 'http://www.truetastes.com/wp-content/themes/anita/ui/img/special_1.jpg'
  end

end

get '/', :provides => 'html' do
  @lunch_special = get_anitas
  haml :index
end

get '/atom', :provides => ['rss', 'atom', 'xml'] do
  @lunch_special = get_anitas

  builder = Nokogiri::XML::Builder.new do |xml|
    xml.feed('xmlns' => 'http://www.w3.org/2005/Atom') {
      xml.link('href' => @lunch_special.url)
      xml.title @lunch_special.title
      xml.updated DateTime.now.to_s
      xml.entry {
        xml.title @lunch_special.title
        xml.content @lunch_special.html_content
        xml.id Digest::MD5.hexdigest(@lunch_special.html_content) 
        xml.updated DateTime.now.to_s
        xml.link('href' => @lunch_special.url)
        xml.link('rel' => 'enclosure', 'href' => @lunch_special.image_uri)
      }
    }
  end

  return builder.to_xml

end

get '/anitas' do
  return get_anitas
end

# new parsing that pulls in their HTML formatting, but we lose the date parsing
def get_anitas

  @lunch_special = LunchSpecial.new
  doc = Nokogiri::HTML(open('http://www.truetastes.com/anitas-cafe-lunch-catering/'))

  ####
  # Search for nodes by css

  if(doc)
    doc.css('div.specials_copy').each do |specials|
        @lunch_special.html_content = specials.inner_html
        @lunch_special.text_content = specials.content
    end
  end

  return @lunch_special

end

# give me back a good image for today's lunch special
def get_relevant_image(lunch_str)

  image = Google::Search::Image.new(:query => lunch_str).first

  if(image)
    return image.thumbnail_uri
  else
    return nil
  end

end
