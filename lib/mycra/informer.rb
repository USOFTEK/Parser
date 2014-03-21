require "sneakers"

module Mycra
	class Informer
		include Sneakers::Worker
		from_queue "informer",
			:threads			=> 1,
			:prefetch			=> 1,
			:timeout_job_after	=> 1

		def work(msg)
			message = Hash.new
			JSON.parse(msg).map { |k,v| message[k.to_sym] = v }
			if self.respond_to?(message[:task])
				self.start_session
				if message.has_key?(:params)
					self.send message[:task].to_sym, message[:params]
				else
					self.send message[:task]
				end
			end
		end
		def status(params)
			response = Hash.new
			response[:threads] = Mycra::Logger.count
			response[:categories] = Mycra::Category.count
			response[:links] = Mycra::Link.count
			response[:categories] = Mycra::Category.count
			response[:product_paths] = Mycra::Link.count
			response[:taxons] = Mycra::Taxon.count
			response[:products] = Mycra::Product.count
			if Mycra::Logger.count > 0
				response[:job_status] = Mycra::Logger.worker_sessions.map { |job, records|
					if job == "collection"
						to_end =  nil
					elsif job == "parse"
						to_end = Mycra::Link.unactive_links.count.to_i * Mycra::Link.count_middle_time.to_i
					end
					"#{job.upcase}: [#{records.count}] END: ~#{to_end}"
				}.join(", ")
			else
				response[:job_status] = "Waiting for a job."
			end
			@queue.exchange.publish(response.to_json, :routing_key => params["routing_key"])
		end
	end
end