require 'sinatra'
require 'digest/md5'
require 'sinatra/activerecord'
require './config/environments'
require './models/model'

set :environment, :production

helpers do
	include Rack::Utils  
	alias_method :h, :escape_html  
	
	def hash(string)
		string.downcase!
		Digest::MD5.hexdigest(string)
	end

	def shorten(string, range)
		string = string.slice(range)
		return string
	end
end

get '/' do
	erb :index
end

post '/' do
	# params[:url] is the url param that has the value of the given longUrl.
	@url = params[:url]

	# Make sure the URL isn't empty.
	if @url.empty?
		@error = "You didn't enter anything!"
		puts "Empty URL submitted."
	end

	# If the URL doesn't have a protocal, add it.
	unless @url.include?("https://") || @url.include?("http://") || @url.empty?
		@url = "http://" + @url
	end
	# If the URL exists and isn't empty then md5/hash it and use the first 6 chars as the code.
	if @url and not @url.empty?
		# Creates a hash of the given longUrl.
		@code = hash(@url)
		@code = shorten(@code, 0..5)
		puts "Code: #{@code}"
		# Send it to the Database.
		db.setnx("link:#{@code}", @url)
	end
	# Then go back to '/'
	erb :index
end

get '/:code' do
	@url = db.get("link:#{params[:code]}")
	redirect @url || '/'
end