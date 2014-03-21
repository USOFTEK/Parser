require "bunny"
require "json"

module Mycra
	class Queue
		def initialize(name, opts)
			@name = name
			@opts = opts
			@cosumer = nil
			@bunny = Bunny.new(@opts)
			@messanger = Bunny.new(@opts[:amqp], :vhost => @opts[:vhost], :heartbeat => @opts[:heartbeat])
			@messanger.start
			@channel = @messanger.create_channel
			@exchange = @channel.exchange(@opts[:exchange], :type => :direct, :durable => @opts[:durable])
		end
		def publish(msg, routing)
			@exchange.publish(msg, :routing_key => routing)
		end
		def subscribe(routing, &callback)
			@queue = @channel.queue(routing, :durable => @opts[:durable])
			@consumer = @queue.bind(@exchange, :routing_key => routing).subscribe { |hdr, mtd, msg|
				message = Hash.new
				JSON.parse(msg).map { |k,v| message[k.to_sym] = v }
				callback.call(hdr, mtd, msg)
			}
		end
		def unsubscribe
			@consumer.cancel if @consumer
			@consumer = nil
		end
	end
end