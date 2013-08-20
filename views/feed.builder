atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.entry( @lunch_special ) do |entry|
    entry.url @lunch_special.url
    entry.title @lunch_special.title
    entry.content @lunch_special.content, :type => 'html'

    # the strftime is needed to work with Google Reader.
    #entry.updated(item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

    #entry.author do |author|
    #  author.name entry.author_name)
    #end
  end
end
