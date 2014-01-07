require 'nokogiri'
require 'open-uri'
require 'sinatra'
require 'haml'
require 'date'
require 'digest/md5'
require 'google-search'

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
      xml.updated get_updated(@lunch_special.text_content)
      xml.entry {
        xml.title @lunch_special.title
        xml.content @lunch_special.html_content
        xml.id Digest::MD5.hexdigest(@lunch_special.html_content) 
        #xml.updated get_updated(@lunch_special.text_content)
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
      specials.xpath('.//p').each do |container|
        # inner HTML example:
        #  <strong>Tuesday,</strong> January 7th, 2014<br><strong>Entree:</strong> Philly Cheese Steak w/ Roasted Potatoes<br><strong>Soups:</strong> Navy Bean w/ Ham &amp; Chicken Spatzel<br><br><br><br><br><br><br><br><strong>Like</strong> us on Facebook! www.facebook.com/anitasandtruetastes<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
        html_content = container.inner_html
        index_of_br = html_content.index('<br><br>')
        better_html_content = html_content[0..index_of_br-1]
        @lunch_special.html_content = better_html_content
        @lunch_special.text_content = container.content
      end
    end
  end

  return @lunch_special

end

# the input to this method is a bit flexible
# e.g. "Tuesday August 20th ENTREE:  Croque Monsieur with Pasta Salad"
# this is probably some of the worst code I have written
# "I'll clean it up later"
# "Yeah, right" 
def get_updated(in_str)
  
  time_string = "January 1st, 1969" 

  if(in_str)
    matches = in_str.match(/^(.+rd)/i)

    if(matches && matches[1])
      # if you think this is messy, then go ahead and fix it, cant figure out how to parse 
      # the input string in my local time zone
      time_string =  DateTime.strptime(matches[1] + ' Central Time (US & Canada)', '%A, %B %erd %Z').to_s
    else
      matches = in_str.match(/^(.+th)/i)

      if(matches && matches[1])
        time_string = DateTime.parse(matches[1]).to_s
        time_string =  DateTime.strptime(matches[1] + ' Central Time (US & Canada)', '%A, %B %eth %Z').to_s
      else
        matches = in_str.match(/^(.+st)/i)

        if(matches && matches[1])
          time_string = DateTime.parse(matches[1]).to_s
          time_string =  DateTime.strptime(matches[1] + ' Central Time (US & Canada)', '%A, %B %est %Z').to_s
        end
      end
    end
  end

  return time_string

end

# Something like this should be called from the above get_updated method,
# but my car is ready, and I don't have any more time
# a date string, with a specified suffix on the day, to parse in my local time zone
def parse_my_date_string(in_date_str, suffix)
  matches = in_str.match(/^(.+st)/i)

  if(matches && matches[1])
    time_string = DateTime.parse(matches[1]).to_s
    puts "Selected date_str: " + matches[1]
    time_string =  DateTime.strptime(matches[1] + ' Central Time (US & Canada)', '%A, %B %est %Z').to_s
  end

  return time_string

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
