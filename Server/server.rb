require	'sinatra'
require 'json'
require 'date'

episodes = [
	{ 
		:number => 80, 
		:published => Date.new(2012, 5, 8),
		:name => "The Killer Eye", 
		:url => "http://badmoviepodcast.com/mp3/e080_killer_eye.mp3", 
		:description => "Creepy Bill and a big sumbitchin’ floating eyeball diddle the breasticles of some starlets in this Full Moon turd kicker. With special guest Dirk the Unfortunate.", 
		:photo => "http://badmoviepodcast.com/images/e080_killer_eye.jpg", 
		:video => "http://www.youtube.com/watch?v=mXOvU5kajr0",
		:imdb => "http://www.imdb.com/title/tt0177886/"
	},
	{ :number => 79, :published => Date.new(2012, 4, 26), :name => "MOON TRAP!", :url => "http://badmoviepodcast.com/mp3/e079_moontrap.mp3", :description => "Walter Koenig and Bruce Campbell’s Chin travel to the moon to battle some really retarded alien robots. Also, boobs.  Guest reviewers: George Lucas, Batman.", :photo => "http://badmoviepodcast.com/images/e079_moontrap.jpg", :video => "http://www.youtube.com/watch?v=s3AJqPtTRx0", :imdb => "http://www.imdb.com/title/tt0097911/" },
	{ :number => 78, :published => Date.new(2012, 4, 03), :name => "Jack and Jill", :url => "http://badmoviepodcast.com/mp3/e078_JackJill.mp3", :description => "Sandler’s cross-dressing comedy “Jack and Jill” swept all 10 categories at the Razzies 2012. It was the first time in the 32-year history of the Razzies that one movie won all of the awards. However, we loved it. What is wrong with us? (Achievement Unlocked: Razzie Dazzle)", :photo => "http://badmoviepodcast.com/images/e078_JackJill.jpg", :video => "http://www.youtube.com/watch?v=_peFu-411Zw", :imdb => "http://www.imdb.com/title/tt0810913/" },
	{ :number => 77, :published => Date.new(2012, 3, 27), :name => "Return of the Killer Tomatoes", :url => "http://badmoviepodcast.com/mp3/e077_ReturnKillerTomatoes.mp3", :description => "George Clooney and Karen Mistal battle John Astin’s killer tomatoes. Funnier than it has any right to be.  4 easy Stella Starrs.", :photo => "http://badmoviepodcast.com/images/e077_ReturnKillerTomatoes.jpg", :video => "http://www.youtube.com/watch?v=_peFu-411Zw", :imdb => "http://www.imdb.com/title/tt0095989/" },
	{ :number => 76, :published => Date.new(2012, 3, 22), :name => "Star Odyssey", :url => "http://badmoviepodcast.com/mp3/e076_StarOdyssey.mp3", :description => "Spaghetti Star Wars. This is pretty much as bad as it can get, I think. Italy made a space movie, and it stinks to the 9th dimension.", :photo => "http://badmoviepodcast.com/images/e076_StarOdyssey.jpg", :video => "http://www.youtube.com/watch?v=_NwikF9LoXY", :imdb => "http://www.imdb.com/title/tt0078317/" }
]

set :public_folder, File.dirname(__FILE__) + '/static'

get '/' do
	"This is the temporary bad movie night API"
end

get '/episodes' do
	puts Time.now
	content_type :json
	episodes.to_json
end

get '/episodes/:episode' do
	content_type :json
	episodes.select { |e| e[:number] == params[:episode].to_i }.to_json
end