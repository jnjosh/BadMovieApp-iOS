require	'sinatra'
require 'json'
require 'date'

# { :number => , :published => Date.new(2012, 4, 26), :name => "", :url => "", :description => "", :photo => "", :video => "", :imdb => "" },

episodes = [
	{ :number => 82, :published => Date.new(2012, 5, 16), :name => "Lunar Cop", :url => "http://badmoviepodcast.com/mp3/e082_lunarcop.mp3", :description => "Post Big-Bird apocalypse, Moonenites have plans to restore Earth to a non-wasteland. They just have to get rid of the annoying people on it. Space is in the title, but motorcycles in the desert is the reality.", :photo => "http://badmoviepodcast.com/images/e082_lunarcop.jpg", :video => "http://www.youtube.com/watch?v=J5EY-_kkhgM", :imdb => "http://www.imdb.com/title/tt0113719/" },
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
	{ :number => 72, :published => Date.new(2012, 2, 01), :name => "The Sword and the Sorcerer", :url => "http://badmoviepodcast.com/mp3/e072_SwordSorceror.mp3", :description => "A Sword with three blades, a girl with two boobs, and a king with one sorcerer. We should have watched cartoons instead.", :photo => "http://badmoviepodcast.com/images/e072_SwordSorceror.jpg", :video => "http://www.youtube.com/watch?v=m7Emt53jHpc", :imdb => "http://www.imdb.com/title/tt0084749/" },
	{ :number => 71, :published => Date.new(2012, 1, 22), :name => "MetalStorm - The Boredom of Jared-Zzzzzz", :url => "http://badmoviepodcast.com/mp3/e071_Metalstorm.mp3", :description => "Metalstorm – The Boredom of Jared-Zzzzzz… This is the 3D sister film to Episode 8 – Space Hunter.  It’s a space western of shitastical proportions.  Just plain bad, but we had fun.", :photo => "http://badmoviepodcast.com/images/e071_Metalstorm.jpg", :video => "http://www.youtube.com/watch?v=Vk1sdBIi53Q", :imdb => "http://www.imdb.com/title/tt0085935/" },
	{ :number => 70, :published => Date.new(2012, 1, 19), :name => "Altered States", :url => "http://badmoviepodcast.com/mp3/e070_AlteredStates.mp3", :description => "Trippy weird psychedelia movie that we sorta like – Altered States. You could say we had a good trip. Nice visuals.", :photo => "http://badmoviepodcast.com/images/e070_AlteredStates.jpg", :video => "http://www.youtube.com/watch?v=MbYT3UclhNY", :imdb => "http://www.imdb.com/title/tt0080360/" },
	{ :number => 69, :published => Date.new(2012, 1, 11), :name => "For Your Height Only", :url => "http://badmoviepodcast.com/mp3/e069_4urheightonly.mp3", :description => "3ft tall phillipino midget James Bond movie. Thank or blame Lugosi, it was his DVD. Also our 2nd year anniversary gala shitfest.", :photo => "http://badmoviepodcast.com/images/e069_4urheightonly.jpg", :video => "http://www.youtube.com/watch?v=F6bW79wMp4w", :imdb => "http://www.imdb.com/title/tt0200642/" },
	{ :number => 68, :published => Date.new(2011, 12, 24), :name => "Santa's Slay", :url => "http://badmoviepodcast.com/mp3/e068_SantasSlay.mp3", :description => "An all-star cast is wiped out in the first 5 minutes, leaving two kids to run from Evil Santa. Curling saves the world. Don’t think too hard, it’ll hurt more.", :photo => "http://badmoviepodcast.com/images/e068_SantasSlay.jpg", :video => "http://www.youtube.com/watch?v=FKrsAFWPnl4", :imdb => "http://www.imdb.com/title/tt0393685/" },
	{ :number => 67, :published => Date.new(2011, 11, 9), :name => "The Dark Backward (WTF BILL PAXTON?!)", :url => "http://badmoviepodcast.com/mp3/e067_DarkBackward.mp3", :description => "WTF Bill Paxton? No, really… WTF?  The Dark Backward is like falling down stairs in slow motion for an hour, into a pile of shit. Danke Shoen.", :photo => "http://badmoviepodcast.com/images/e067_DarkBackward.jpg", :video => "http://www.youtube.com/watch?v=9L_pcXuJ384", :imdb => "http://www.imdb.com/title/tt0101660/" },
	{ :number => 66, :published => Date.new(2011, 10, 11), :name => "Interview With Big Chuck", :url => "http://badmoviepodcast.com/mp3/e066_BigChuck.mp3", :description => "This is the most important episode of this podcast. Period. I talk to Chuck Schodowski, without whom this show wouldn’t exist. Chuck and John Rinaldi are the cohosts of the Big Chuck & Lil John show, on TV8 in Cleveland from 1979-2007.", :photo => "http://badmoviepodcast.com/images/e066_BigChuck.jpg", :video => "http://www.youtube.com/watch?v=9kMNKfRgAVg", :imdb => "http://www.imdb.com/name/nm1727907/" },
	{ :number => 65, :published => Date.new(2011, 10, 07), :name => "DeathSport", :url => "http://badmoviepodcast.com/mp3/e065_deathsport.mp3", :description => "David Carradine and a playmate re-enact Lord of the Rings on motorcycles. Not really. It’s worse than that.", :photo => "http://badmoviepodcast.com/images/e065_deathsport.jpg", :video => "http://www.youtube.com/watch?v=ehh2ltAHecM", :imdb => "http://www.imdb.com/title/tt0077414/" },
	{ :number => 64, :published => Date.new(2011, 10, 05), :name => "Karate Dog", :url => "http://badmoviepodcast.com/mp3/e064_karatedog.mp3", :description => "Karate Dog. Watching this movie with your kids is pretty much child abuse in 43 states. This will not end well.", :photo => "http://badmoviepodcast.com/images/e064_karatedog.jpg", :video => "http://www.youtube.com/watch?v=McGqeq600D8", :imdb => "http://www.imdb.com/title/tt0270882/" },
	{ :number => 63, :published => Date.new(2011, 9, 23), :name => "Frankenstein Island", :url => "http://badmoviepodcast.com/mp3/e063_FrankensteinIsland.mp3", :description => "THE POWER! THE POWER! THE SUCKAGE! The zombies! The pirates! The bikini cave women FROM SPACE!!", :photo => "http://badmoviepodcast.com/images/e063_FrankensteinIsland.jpg", :video => "http://www.youtube.com/watch?v=5u8W5UFUGiM", :imdb => "http://www.imdb.com/title/tt0082410/" },
	{ :number => 62, :published => Date.new(2011, 9, 18), :name => "Heartbeeps", :url => "http://badmoviepodcast.com/mp3/e062_Heartbeeps.mp3", :description => "A story of robots in love. Reproduction. Running out of batteries. Be SURE to listen to the 2nd half. We did an after-show where I left the mics on during our usual post-mortem bullshit session.", :photo => "http://badmoviepodcast.com/images/e062_Heartbeeps.jpg", :video => "http://www.youtube.com/watch?v=eJMm7Bcgho4", :imdb => "http://www.imdb.com/title/tt0082507/" },
	{ :number => 61, :published => Date.new(2011, 8, 30), :name => "LifeForce", :url => "http://badmoviepodcast.com/mp3/e061_lifeforce.mp3", :description => "Warning! Space Vampire shitfest ahead. You have been warned. But hey, on the bright side… BOOBS!", :photo => "http://badmoviepodcast.com/images/e061_lifeforce.jpg", :video => "http://www.youtube.com/watch?v=KqNquDlAanE", :imdb => "http://www.imdb.com/title/tt0089489/" },
	{ :number => 60, :published => Date.new(2011, 8, 14), :name => "Discount Cowboys and Aliens", :url => "http://badmoviepodcast.com/mp3/e060_Oblivion.mp3", :description => "1994′s Oblivion. This is Cowboys and Aliens, but with George Takei and Musetta Vander instead of James Bond and Indianna Jones. End result is the same though. Cowboys and Bullshit.", :photo => "http://badmoviepodcast.com/images/e060_Oblivion.jpg", :video => "http://www.youtube.com/watch?v=5buqVnYiswA", :imdb => "http://www.imdb.com/title/tt0110706/" }
]

set :public_folder, File.dirname(__FILE__) + '/static'

before do
  cache_control :public, :must_revalidate, :max_age => 60
end

get '/' do
	redirect "/episodes"
end

get '/episodes' do
	last_modified Date.new(2012, 5, 16)
	content_type :json
	episodes.to_json
end

get '/episodes/:episode' do
	last_modified episodes.first[:published]
	content_type :json
	episodes.select { |e| e[:number] == params[:episode].to_i }.to_json
end