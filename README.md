# Anita's Daily Special

Parse Anita's website and pull out the daily special. Obviously this is highly
reliant on the structure of the HTML returned.

http://truetastes.com/anitas-cafe/

As of 2/2018, they updated their website, and are publishing a week's content
at a time. This program will bring that list in, and give a day at a time if that
is desired.

Designed to return an atom feed, but can also return HTML.

### Prerequisites

ruby 2.x.x and an environment that will build nokogiri. This is a sinatra app.

## Running the tests

Uses rspec for testing.

To run the tests just run

```
rake
```

## Using it

`/weekly` returns an atom feed containing all the content for the current week

`/daily` returns an atom feed containing just that days content. Note that Anita's doesn't provide specials for the weekend, so if this runs on Saturday or Sunday the feed will be empty.

`/daily?day=Monday` returns an atom feed containing just Monday's content

## Deployment

I've been deploying this to heroku, works great there.

## Built With

* [Sinatra](http://sinatrarb.com/) - The web framework used
* [Rspec](http://recipes.sinatrarb.com/p/testing/rspec) - Testing framework
* [Nokogiri](http://www.nokogiri.org/) - Used to parse HTML and generate RSS Feeds

## Authors

* **Torleiv Flatebo** - *Initial work* - [tflatebo](https://github.com/tflatebo)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
