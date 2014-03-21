require "mongoid"
require "mongoid-locker"

module Mycra
	module Model
		class Asset
			include Mongoid::Document
			include Mongoid::Locker

			field	:attachment_width,			type: Integer
			field	:attachment_height,			type: Integer
			field	:attachment_file_size,		type: Integer
			field	:position,					type: Integer, default: 0
			field	:attachment_content_type,	type: String
			field	:type,						type: String
			field	:name,						type: String
			field	:data,						type: String

			belongs_to :product, class_name: "Mycra::Model::Product"

			validates_presence_of :data, :attachment_content_type, :attachment_width, :attachment_height, :attachment_file_size, :name
		end
	end
end