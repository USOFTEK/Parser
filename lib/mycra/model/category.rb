require "mongoid"
require "mongoid-locker"
require "mongoid_nested_set"

module Mycra
	module Model
		class Category
			include Mongoid::Document
			include Mongoid::Locker

			field	:name,		type: String
			field	:href,		type: String
			field	:reference,	type: String
			field	:status,	type: Boolean
			has_many 	:links
			acts_as_nested_set

			validates	:name, uniqueness: true, presence: true
			validates	:reference, uniqueness: true, presence: true
			validates	:href, presence: true

			def self.save_category(data)
				find_or_create_by(:name => data[:name]).update_attributes(:href => data[:href], :reference => data[:md5])
			end
		end
	end
end