describe "Anitas Lunch Special" do
  it "should return html at root" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('<!DOCTYPE html>')
  end

  it "should return an atom feed with specified days content" do
    get '/daily?day=Monday'
    expect(last_response).to be_ok
    expect(last_response.body).to include('<?xml version="1.0"?>')
    expect(last_response.body).to include('<entry>') # it has an entry in the feed, which means it should have content
    expect(last_response.body).to include('<title>Anita\'s Daily Lunch Special</title>')
    expect(last_response.body).to include('&gt;Monday, ')
    expect(last_response.body.scan(/(?=Soups)/).count).to eql 1
  end

  it "should return an empty atom feed on Saturday" do
    get '/daily?day=Saturday'
    expect(last_response).to be_ok
    expect(last_response.body).to include('<?xml version="1.0"?>')
    expect(last_response.body).to include('<title>Anita\'s Daily Lunch Special</title>')
    expect(last_response.body).to_not include('<entry>') # it has an entry in the feed, which means it should have content
    expect(last_response.body.scan(/(?=Soups)/).count).to eql 0
  end

  it "should return the whole week" do
    get '/weekly'
    expect(last_response).to be_ok
    expect(last_response.body).to include('<?xml version="1.0"?>')
    expect(last_response.body).to include('<entry>') # it has an entry in the feed, which means it should have content
    expect(last_response.body).to include('<title>Anita\'s Daily Lunch Special</title>')
    expect(last_response.body).to include('&gt;Monday, ')
    expect(last_response.body).to include('&gt;Tuesday, ')
    expect(last_response.body).to include('&gt;Wednesday, ')
    expect(last_response.body).to include('&gt;Thursday, ')
    expect(last_response.body).to include('&gt;Friday, ')
    expect(last_response.body.scan(/(?=Soups)/).count).to eql 5
  end

  it "should parse the days" do
    @test_data = Hash.new
    @test_data['specials_html'] = "<p><strong>Monday, February 5th, 2018</strong></p>
    <p>Entrée: Beef Sliders with Roasted Potatoes</p>
    <p>Soups: Tortilla Chip Chicken &amp; Navy Bean with Ham</p>
    <p><strong>Tuesday, February 6th, 2018</strong></p>
    <p>Entrée: Buffalo Chicken Wrap with Fresh Fruit</p>
    <p>Soups: Chicken Spaetzle &amp; Cream of Broccoli</p>
    <p>Beef Taco Salad</p>
    <p><strong>Wednesday, <b>February </b>7th, 2018 </strong></p>
    <p>Entrée: Juicy Lucy with a Side of Coleslaw</p>
    <p>Soups: Lemon Chicken Rice &amp; Black Bean Chorizo</p>
    <p>Chicken Taco Salad</p>
    <p><strong>Thursday, February 8th, 2018<br></strong></p>
    <p>Entrée: Meatball Sliders with Side of Spaghetti  </p>
    <p>Soups: MN Wild Rice with Chicken &amp; Italian Tomato</p>
    <p>Beef Taco Salad</p>
    <p><strong>Friday, <b>February </b>9th, 2018</strong></p>
    <p>Entrée: Stuffed Chicken Pasta with Fresh Whipped Potatoes</p>
    <p>Soups: Chicken Peppernoodle &amp; Split Pea with Ham</p>
    <p>Chicken Taco Salad</p>"

    lunch_special = Anitas.new
    daily_specials = lunch_special.parse_days(@test_data['specials_html'])

    expect(daily_specials).to include('Monday' => '<strong>Monday, February 5th, 2018</strong><p>Entrée: Beef Sliders with Roasted Potatoes</p><p>Soups: Tortilla Chip Chicken &amp; Navy Bean with Ham</p>')
    expect(daily_specials).to include('Tuesday' => '<strong>Tuesday, February 6th, 2018</strong><p>Entrée: Buffalo Chicken Wrap with Fresh Fruit</p><p>Soups: Chicken Spaetzle &amp; Cream of Broccoli</p><p>Beef Taco Salad</p>')
    expect(daily_specials).to include('Wednesday' => '<strong>Wednesday, <b>February </b>7th, 2018 </strong><p>Entrée: Juicy Lucy with a Side of Coleslaw</p><p>Soups: Lemon Chicken Rice &amp; Black Bean Chorizo</p><p>Chicken Taco Salad</p>')
    expect(daily_specials).to include('Thursday' => '<strong>Thursday, February 8th, 2018<br></strong><p>Entrée: Meatball Sliders with Side of Spaghetti  </p><p>Soups: MN Wild Rice with Chicken &amp; Italian Tomato</p><p>Beef Taco Salad</p>')
    expect(daily_specials).to include('Friday' => '<strong>Friday, <b>February </b>9th, 2018</strong><p>Entrée: Stuffed Chicken Pasta with Fresh Whipped Potatoes</p><p>Soups: Chicken Peppernoodle &amp; Split Pea with Ham</p><p>Chicken Taco Salad</p>')
  end

  it "should return just one days content" do
    @test_data = Hash.new
    @test_data['specials_html'] = "<p><strong>Monday, February 5th, 2018</strong></p>
    <p>Entrée: Beef Sliders with Roasted Potatoes</p>
    <p>Soups: Tortilla Chip Chicken &amp; Navy Bean with Ham</p>
    <p><strong>Tuesday, February 6th, 2018</strong></p>
    <p>Entrée: Buffalo Chicken Wrap with Fresh Fruit</p>
    <p>Soups: Chicken Spaetzle &amp; Cream of Broccoli</p>
    <p>Beef Taco Salad</p>
    <p><strong>Wednesday, <b>February </b>7th, 2018 </strong></p>
    <p>Entrée: Juicy Lucy with a Side of Coleslaw</p>
    <p>Soups: Lemon Chicken Rice &amp; Black Bean Chorizo</p>
    <p>Chicken Taco Salad</p>
    <p><strong>Thursday, February 8th, 2018<br></strong></p>
    <p>Entrée: Meatball Sliders with Side of Spaghetti  </p>
    <p>Soups: MN Wild Rice with Chicken &amp; Italian Tomato</p>
    <p>Beef Taco Salad</p>
    <p><strong>Friday, <b>February </b>9th, 2018</strong></p>
    <p>Entrée: Stuffed Chicken Pasta with Fresh Whipped Potatoes</p>
    <p>Soups: Chicken Peppernoodle &amp; Split Pea with Ham</p>
    <p>Chicken Taco Salad</p>"

    anitas = Anitas.new
    daily_specials = anitas.parse_days(@test_data['specials_html'])

    day = anitas.get_day('Monday')
    expect(day).to include('<strong>Monday, February 5th, 2018</strong><p>Entrée: Beef Sliders with Roasted Potatoes</p><p>Soups: Tortilla Chip Chicken &amp; Navy Bean with Ham</p>')

    day = anitas.get_day('Tuesday')
    expect(day).to include('<strong>Tuesday, February 6th, 2018</strong><p>Entrée: Buffalo Chicken Wrap with Fresh Fruit</p><p>Soups: Chicken Spaetzle &amp; Cream of Broccoli</p><p>Beef Taco Salad</p>')

    day = anitas.get_day('Wednesday')
    expect(day).to include('<strong>Wednesday, <b>February </b>7th, 2018 </strong><p>Entrée: Juicy Lucy with a Side of Coleslaw</p><p>Soups: Lemon Chicken Rice &amp; Black Bean Chorizo</p><p>Chicken Taco Salad</p>')

    day = anitas.get_day('Thursday')
    expect(day).to include('<strong>Thursday, February 8th, 2018<br></strong><p>Entrée: Meatball Sliders with Side of Spaghetti  </p><p>Soups: MN Wild Rice with Chicken &amp; Italian Tomato</p><p>Beef Taco Salad</p>')

    day = anitas.get_day('Friday')
    expect(day).to include('<strong>Friday, <b>February </b>9th, 2018</strong><p>Entrée: Stuffed Chicken Pasta with Fresh Whipped Potatoes</p><p>Soups: Chicken Peppernoodle &amp; Split Pea with Ham</p><p>Chicken Taco Salad</p>')

  end

end
