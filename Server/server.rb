require	'sinatra'
require 'json'
require 'date'

episodes = [
	{ 
		:number => 80, 
		:published => Date.new(2012, 5, 8),
		:name => "Episode 80: The Killer Eye", 
		:url => "http://badmoviepodcast.com/mp3/e080_killer_eye.mp3", 
		:description => "Creepy Bill and a big sumbitchin’ floating eyeball diddle the breasticles of some starlets in this Full Moon turd kicker. With special guest Dirk the Unfortunate.", 
		:photo => "http://badmoviepodcast.com/images/e080_killer_eye.jpg", 
		:video => "http://www.youtube.com/watch?v=mXOvU5kajr0",
		:imdb => "http://www.imdb.com/title/tt0177886/"
	},
	{ :number => 79, :published => Date.new(2012, 4, 26), :name => "Episode 79: MOON TRAP!", :url => "http://badmoviepodcast.com/mp3/e079_moontrap.mp3", :description => "Walter Koenig and Bruce Campbell’s Chin travel to the moon to battle some really retarded alien robots. Also, boobs.  Guest reviewers: George Lucas, Batman.", :photo => "http://badmoviepodcast.com/images/e079_moontrap.jpg", :video => "http://www.youtube.com/watch?v=s3AJqPtTRx0", :imdb => "http://www.imdb.com/title/tt0097911/" }
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