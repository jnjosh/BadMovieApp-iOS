require	'sinatra'
require 'json'
require 'date'

# { :number => , :published => Date.new(2012, 4, 26), :name => "", :url => "", :description => "", :photo => "", :video => "", :imdb => "" },

episodes = [
	{ :number => 81, :published => Date.new(2012, 5, 10), :name => "Iron Eagle", :url => "http://badmoviepodcast.com/mp3/e081_ironeagle.mp3", :description => "Grand theft F-16. This is “Not Top Gun”, but rather a movie about adult incompetence and teenage empowerment. Also, the power of Freddy Mercury to give you super powers. Use the force, Doug.", :photo => "http://badmoviepodcast.com/images/e081_ironeagle.jpg", :video => "http://www.youtube.com/watch?v=vSR6sxi1RTo", :imdb => "http://www.imdb.com/title/tt0091278/" },
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
	{ :number => 76, :published => Date.new(2012, 3, 22), :name => "Star Odyssey", :url => "http://badmoviepodcast.com/mp3/e076_StarOdyssey.mp3", :description => "Spaghetti Star Wars. This is pretty much as bad as it can get, I think. Italy made a space movie, and it stinks to the 9th dimension.", :photo => "http://badmoviepodcast.com/images/e076_StarOdyssey.jpg", :video => "http://www.youtube.com/watch?v=_NwikF9LoXY", :imdb => "http://www.imdb.com/title/tt0078317/" },
	{ :number => 75, :published => Date.new(2012, 2, 25), :name => "Subspecies", :url => "http://badmoviepodcast.com/mp3/e075_Subspecies.mp3", :description => "We let Radu drool all over this one. An ancient ugly is loose in Transylvania… and he’s… JUICY.", :photo => "http://badmoviepodcast.com/images/e075_Subspecies.jpg", :video => "http://www.youtube.com/watch?v=OP3rbLu4qDY", :imdb => "http://www.imdb.com/title/tt0103002/" },
	{ :number => 74, :published => Date.new(2012, 2, 22), :name => "Ghost Rider Vengeance", :url => "http://badmoviepodcast.com/mp3/e074_GhostRider2.mp3", :description => "We recorded this in a bar. Really. Ghost Rider 2 was everything we wanted it to be. We loved it deeply. Don’t believe the haters. Nic brought the CAGE RAGE in full force. 5 hellified Stella Stars!", :photo => "http://badmoviepodcast.com/images/e074_GhostRider2.jpg", :video => "http://www.youtube.com/watch?v=purgXaoqhPY", :imdb => "http://www.imdb.com/title/tt1071875/" },
	{ :number => 73, :published => Date.new(2012, 2, 19), :name => "7th Curse (WTF Asia?!?)", :url => "http://badmoviepodcast.com/mp3/e073_7thCurse.mp3", :description => "Chow Yun Fat uses a battle fetus and rocket launcher to kill the Crypt Keeper in this WTF Asia masterpiece. It has a BABY JUICER in it. I can’t make this shit up.", :photo => "http://badmoviepodcast.com/images/e073_7thCurse.jpg", :video => "http://www.youtube.com/watch?v=JLbdJfiabK8", :imdb => "http://www.imdb.com/title/tt0092273/" },
	{ :number => 72, :published => Date.new(2012, 2, 01), :name => "The Sword and the Sorcerer", :url => "http://badmoviepodcast.com/mp3/e072_SwordSorceror.mp3", :description => "A Sword with three blades, a girl with two boobs, and a king with one sorcerer. We should have watched cartoons instead.", :photo => "http://badmoviepodcast.com/images/e072_SwordSorceror.jpg", :video => "http://www.youtube.com/watch?v=m7Emt53jHpc", :imdb => "http://www.imdb.com/title/tt0084749/" }
]

set :public_folder, File.dirname(__FILE__) + '/static'

get '/' do
	redirect "/episodes"
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