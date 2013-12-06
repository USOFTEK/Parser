module MyCrawler
	class Log
		include Mongoid::Document
		include Mongoid::Locker

		field	:name,		type: String
		field	:href,		type: String
		field	:status,	type: String
		field	:in_use,	type: String
		field	:taxon_id,	type: Integer
		

	end

	class Proxies
		include Mongoid::Document
		include Mongoid::Locker

		field	:host,		type: String
		field	:port,		type: Integer
		field	:username,	type: String
		field	:password,	type: String
		field	:status,	type: Boolean

	end


	class Config
		include Mongoid::Document
		include Mongoid::Locker

		field	:key,		type: String
		field	:value,		type: String

	end

	class Taxonomies
		include Mongoid::Document
		include Mongoid::Locker

		field	:name,			type:	String
		field	:position,		type: 	Integer
		field	:created_at,	type: 	DateTime
		field	:updated_at,	type: 	DateTime

		has_many	:taxons, dependent: :delete

	end

	class Taxons
		include Mongoid::Document
		include Mongoid::Locker
		include Mongoid::Ancestry

		has_ancestry

		field	:name,				type: String
		field	:parent_id,			type: Integer
		field	:taxonomy_id,		type: Integer
		field	:description,		type: String
		field	:meta_description,	type: String
		field	:meta_keywords,		type: String
		field	:meta_title,		type: String
		field	:depth,				type: Integer
		field	:position,			type: Integer
		field	:permalink,			type: String
		field	:lft,				type: Integer
		field	:rgt,				type: Integer
		field	:icon_file_name,	type: String
		field	:icon_file_type,	type: Integer
		field	:icon_uploaded_at,	type: DateTime
		field	:created_at,		type: DateTime
		field	:updated_at,		type: DateTime

		belongs_to	:taxonomy
		has_many	:products

	end

	class Products
		include Mongoid::Document
		include Mongoid::Locker

		field	:name,					type: String
		field	:description,			type: String
		field	:availiable_on,			type: DateTime
		field	:permalink,				type: String
		field	:meta_description,		type: String
		field	:meta_keywords,			type: String
		field	:tax_category_id,		type: Integer
		field	:shipping_category_id,	type: Integer
		field	:created_at,			type: DateTime
		field	:updated_at,			type: DateTime
		field	:deleted_at,			type: DateTime

		belongs_to	:taxon

	end

	class Properties
		include Mongoid::Document
		include Mongoid::Locker

		field	:name,			type: String
		field	:presentation,	type: String
		field	:created_at,	type: DateTime
		field	:updated_at,	type: DateTime

	end

	class Prototypes
		include Mongoid::Document
		include Mongoid::Locker

		field	:name,			type: String
		field	:created_at,	type: DateTime
		field	:updated_at,	type: DateTime

	end

	class OptionTypes
		include Mongoid::Document
		include Mongoid::Locker

		field	:name,			type: String
		field	:presentation,	type: String
		field	:position,		type: Integer
		field	:created_at,	type: DateTime
		field	:updated_at,	type: DateTime

	end

end