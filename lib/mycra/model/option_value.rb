require "mongoid"
require "mongoid-locker"

module Mycra
	module Model
		class OptionValue
			include Mongoid::Document
			include Mongoid::Locker

			field	:value,			type: String
			field	:presentation,	type: String
			field	:position,		type: Integer, default: 0

			has_and_belongs_to_many :option_types, class_name: "Mycra:Model:OptionType"

			validates_presence_of :name, :presentation
		end
	end
end