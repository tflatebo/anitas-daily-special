require 'nokogiri'
require 'open-uri'
require 'sinatra'
require 'haml'
require 'date'
require 'digest/md5'
require 'yaml'
require 'pry'

class Anitas
  attr_accessor :title, :url, :text_content, :html_content, :image_uri, :selector, :specials

  def initialize
    config = YAML.load_file('config/config.yml')

    @title = config['title']
    @url = config['url']
    @content = config['default_content']
    @image_uri = config['image_uri']
    @selector = config['selector']

    @specials = {}
  end

  # give me just the days content, to be able to run this once per day
  # and only give me that days content rather than the whole week
  def get_day(day_name)
    return @specials[day_name]
  end

  # new parsing that pulls in their HTML formatting, but we lose the date parsing
  def get_specials

    begin
      doc = Nokogiri.HTML(open(@url))
    rescue Exception => e
      puts "Couldn't read \"#{ url }\": #{ e }\ndoc.errors"
      exit
    end

    ####
    # Search for nodes by css

    if(doc)
      doc.css(@selector).each do |specials|
          @html_content = specials.inner_html
          @text_content = specials.content

          parse_days(@html_content)
      end
    end
  end

  # parse the html for the daily special, then put them
  # into a hash by the day of the week and return the hash
  # example input (2/2018):
  # <p><strong>Monday, February 5th, 2018</strong></p>
  # <p>Entrée: Beef Sliders with Roasted Potatoes</p>
  # <p>Soups: Tortilla Chip Chicken &amp; Navy Bean with Ham</p>
  def parse_days(html)

    @days = Hash.new
      flag = nil
      parsed_html = Nokogiri::HTML.fragment(html)

      parsed_html.css('p').each do | p |
        day_element = p.css('strong')

        if(!(day_element.empty?))
          day_match = day_element.inner_html.match(/(\w+), (.*), (\d+)/)

          if(day_match)
            @days[day_match[1]] = day_element.to_html
            flag = day_match[1]
          end
        elsif(@days[flag])
          @days[flag] << p.to_html
        end
      end

    @specials = @days
    return @days
  end
end

def generate_atom_feed(content, url, title)
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.feed('xmlns' => 'http://www.w3.org/2005/Atom') {
      xml.link('href' => url)
      xml.title title
      xml.updated DateTime.now.to_s
      if(content)
        xml.entry {
          xml.title title
          xml.content content
          xml.id Digest::MD5.hexdigest(content)
          xml.updated DateTime.now.to_s
          xml.link('href' => url)
        }
      end
    }
  end

  return builder.to_xml
end

# give me the whole week as html
get '/', :provides => 'html' do
  @anitas = Anitas.new
  @anitas.get_specials
  haml :index
end

# give me the just today's content as an atom feed
get '/daily', :provides => ['rss', 'atom', 'xml'] do
  @anitas = Anitas.new
  @anitas.get_specials

  if(params['day'])
    content = @anitas.get_day(params['day'])
  else
    content = @anitas.get_day(Time.now.strftime("%A"))
  end

  return generate_atom_feed(content, @anitas.url, @anitas.title)
end

# give me the whole week's content as an atom feed
get '/weekly', :provides => ['rss', 'atom', 'xml'] do
  @anitas = Anitas.new
  @anitas.get_specials

  return generate_atom_feed(@anitas.html_content, @anitas.url, @anitas.title)
end
