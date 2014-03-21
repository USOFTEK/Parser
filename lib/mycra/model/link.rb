require "mongoid"
require "mongoid-locker"
require "mongoid_nested_set"

module Mycra
	module Model
		class Link
			include Mongoid::Document
			include Mongoid::Locker

			include Mongoid::Document
			include Mongoid::Locker
			field	:name,		type: String
			field	:href,		type: String
			field	:referer,	type: String
			field	:reference,	type: String
			field	:status,	type: Boolean, default: false
			field	:time,		type: Float
			belongs_to 	:category

			validates	:name, presence: true
			validates	:href, presence: true
			validates	:referer, presence: true
			validates	:time, presence: true

			scope :unactive_links, where(:status => false)

			def self.count_middle_time
				if where(:time.ne => nil).count > 0
					where(:time.ne => nil).to_a.inject { |sum, x| sum + x } / where(:time.ne => nil).count
				else
					0
				end
			end
		end
	end
end