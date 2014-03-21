require "mongoid"
require "mongoid-locker"

module Mycra
	module Model
		class Logger
			include Mongoid::Document
			include Mongoid::Locker

			field	:name,		type: String
			field	:status,	type: Boolean
			field	:errors,	type: Integer
			field	:job,		type: String
			
			def self.worker_sessions
				only(:job).group_by(&:job)
			end
			def self.create_session(name, job)
				first_or_create_by(:name => name, :job => job)
			end
			def self.destroy_session(name, job)
				where(:name => name, :job => job).destroy
			end
		end
	end
end