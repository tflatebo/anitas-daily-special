require 'nokogiri'
require 'open-uri'
require 'sinatra'
require 'haml'
require 'date'
require 'digest/md5'

class LunchSpecial
  attr_accessor :title, :url, :content

  def initialize
    @title = "Anita's Daily Lunch Special"
    @url = 'http://www.truetastes.com/anitas-cafe-lunch-catering/'
    @content = 'whipped potatoes'
  end

end

get '/', :provides => 'html' do
  @lunch_special = get_anitas
  haml :index
end

get '/atom', :provides => ['rss', 'atom', 'xml'] do
  @lunch_special = LunchSpecial.new
  @lunch_special.content = get_anitas

  builder = Nokogiri::XML::Builder.new do |xml|
    xml.feed('xmlns' => 'http://www.w3.org/2005/Atom') {
      xml.link('href' => @lunch_special.url)
      xml.title @lunch_special.title
      xml.updated get_updated(@lunch_special.content)
      xml.entry {
        xml.title @lunch_special.title
        xml.content @lunch_special.content
        xml.id Digest::MD5.hexdigest(@lunch_special.content)
        xml.updated get_updated(@lunch_special.content)
        xml.link('href' => @lunch_special.url)
      }
    }
  end

  return builder.to_xml

end

get '/anitas' do
  return get_anitas
end

def get_anitas

  lunch_special = "Whipped potatoes"

  doc = Nokogiri::HTML(open('http://www.truetastes.com/anitas-cafe-lunch-catering/'))

  ####
  # Search for nodes by css

  if(doc)
    doc.css('div.specials_copy').each do |specials|
      specials.xpath('.//p').each do |container|
        inner_text = container.content
        # ex: "Monday September 3rdENTREE: Hawaiin Chicken SandwichSOUPS: Navy Bean with Ham & Tortilla Chip Chicken   WE'RE FACEBOOK OFFICIAL! www.facebook.com/anitasandtruetastes"
        puts "Inner Text: " + inner_text
        if(inner_text)
          matches = inner_text.match(/^(.+)SOUP.{0,1}:/i)

          if(matches && matches[1])
            lunch_special = matches[1]
            need_space = lunch_special.match(/^(.*[^\s])(ENTREE.*)/i)
            if(need_space)
              lunch_special = "<strong>" + need_space[1] + "</strong><br/>" + need_space[2] + "\n"
            end
          end
        end
      end
    end
  end

  return lunch_special

end

# the input to this method is a bit flexible
# e.g. "Tuesday August 20th ENTREE:  Croque Monsieur with Pasta Salad"
def get_updated(in_str)
  
  time_string = "January 1, 1969"

  if(in_str)
    matches = in_str.match(/^(.+)ENTREE:/i)

    if(matches && matches[1])
      time_string = DateTime.parse(matches[1]).to_s
    end
  end

  return time_string

end

