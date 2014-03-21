require "mongoid"
require "mongoid-locker"

module Mycra
	module Model
		class OptionType
			include Mongoid::Document
			include Mongoid::Locker

			field	:name,			type: String
			field	:presentation,	type: String
			field	:position,		type: Integer, default: 0

			has_and_belongs_to_many :prototypes, class_name: "Mycra::Model::Prototype"
			has_and_belongs_to_many :products, class_name: "Mycra::Model::Product"
			has_and_belongs_to_many :option_values, class_name: "Mycra:Model:OptionValue"

			validates_presence_of :name, :presentation
		end
	end
end