require "mongoid"
require "mongoid-locker"

module Mycra
	module Model
		class Proxy
			include Mongoid::Document
			include Mongoid::Locker

			field	:host,	type: String
			field	:port,	type: Integer
			field	:user,	type: String
			field	:pass,	type: String

			validates	:host, presence: true, format: { with: /[\w\.]+/i }
			validates	:port, format: { with: /\d+/ }

			def self.load_from_yml(path)
				YAML.load_file(path).each { |row|
					find_or_create_by(row)
				}
			end
			def self.load_from_csv(path)
				CSV.foreach(File.dirname(__FILE__) + "/test.csv") { |row|
					record = {:host => row[0], :port => row[1]}
					record[:user] = "" unless row[2].nil?
					record[:pass] = "" unless row[3].nil?
					find_or_create_by(record)
				}
			end
		end
	end
end