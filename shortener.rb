require 'sinatra'
require 'redis'
require 'digest/md5'

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