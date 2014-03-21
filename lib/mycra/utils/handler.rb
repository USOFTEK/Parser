module Mycra
	module Handler
		class ExponentialRetry
			def initialize(channel)
				@channel = channel
			end
			def acknowledge(tag)
				Mycra::Logger.where(:name => Thread.current.object_id.to_s(36)).destroy
				@channel.acknowledge(tag, false)
			end
			def reject(tag, requeue = false)
				Mycra::Logger.where(:name => Thread.current.object_id.to_s(36)).destroy
				@channel.reject(tag, requeue)
			end
			def error(tag, error)
				log = Mycra::Logger.where(:name => Thread.current.object_id.to_s(36))
				log.error = log.errors.to_i + 1
				log.save
				reject(tag)
			end
			def timeout(tag)
				reject(tag)
			end
		end
	end
end