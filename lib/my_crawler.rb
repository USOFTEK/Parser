require "my_crawler/version"
require "config/config"
require "controller/action"

Dir[File.dirname(__FILE__) + '/database/*.rb'].each { |file| require file }

module MyCrawler
  class Yandex
	def initialize
		
		@commands = ["start", "stop", "restart", "status"]
		
		@http = require('http'),
		@faye = require('faye');
		
		@server = http.createServer(),
		@bayeux = new faye.NodeAdapter({mount: '/'});
		
		@bayeux.attach(@server);
		@server.listen(8000);
	end
	def run
  		EM.run {
			@client = new Faye.Client('http://localhost:8000/');
			@client.subscribe('/tasks', function(message) {
				if @commands.inclue? message.command.downcase.chomp.to_sym
					self.send message.command.downcase.chomp.to_sym
				else
					@client.publish('/tasks', {
						text: "Undefined command '#{message.command}'! Try again."
					})
				end
			});	
  		}
  	end
  	def start
  		
  	end
  	def stop
  		
  	end
  	def restart
  		
  	end
  	def status
  		if EM.defers_finished?
  			@client.publish('/tasks', { text: "Awaiting job...".to_json })
  		else
  			
  		end
  	end
  end
end
