require "mongoid"
require "mongoid-locker"
require "mongoid_nested_set"

module Mycra
	module Model
		class Property
			include Mongoid::Document
			include Mongoid::Locker

			field	:name,			type: String
			field	:presentation,	type: String

			has_and_belongs_to_many :products, class_name: "Mycra::Model::Product"
			has_and_belongs_to_many :prototypes, class_name: "Mycra::Model::Prototype"
			has_and_belongs_to_many :option_types, class_name: "Mycra::Model::Prototype"			

			validates_presence_of :name, :presentation
		end
	end
end