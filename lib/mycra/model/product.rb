require "mongoid"
require "mongoid-locker"
require "mongoid_nested_set"

module Mycra
	module Model
		class Product
			include Mongoid::Document
			include Mongoid::Locker

			field	:name,			type: String
			field	:description,	type: String

			acts_as_nested_set
			has_and_belongs_to_many :taxons, class_name: "Mycra::Model::Taxon"
			has_and_belongs_to_many :properties, class_name: "Mycra::Model::Property"
			has_many :variants, class_name: "Mycra::Model::Variant"
		end
	end
end