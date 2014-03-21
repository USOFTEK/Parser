require "mongoid"
require "mongoid-locker"
require "mongoid_nested_set"

module Mycra
	module Model
		class Taxon
			include Mongoid::Document
			include Mongoid::Locker

			field	:name,			type: String
			field	:description,	type: String
			field	:position,		type: Integer, default: 0

			acts_as_nested_set
			has_and_belongs_to_many :products, class_name: "Mycra::Model::Product"

			validates :name, presence: true
		end
	end
end