
module MyCrawler
	class Config
		def proxy=(path)
			data = []
			case File.extname(path)
			when ".csv"
				CSV.open(File.dirname(__FILE__) + '/test.csv', skip_blanks: true) { |csv|
					csv.each { |row|
						data.push({ "host" => row[0], "port" => row[1], "username" => row[2], "password" => row[3] })
					}
				}
			when ".yml"
				data = YAML::load(path)
			else
				puts "File type is not supported"
			end
			@proxies = data if data.kind_of?(Array)
		end
		def proxy
			@proxies
		end
		def db_host=(host)
			@db_host = host
		end
		def db_host
			@db_host
		end
		def db_port(port)
			@db_port = port.kind_of?(Integer) ? port : 27017
		end
		def db_user=(username)
			@db_user = username.nil? ? "username" : user
		end
		def db_user
			@db_user
		end
		def db_password=(password)
			@db_password = password.nil? ? "password" : password
		end
		def db_password
			@db_password
		end
		def limit=(limit)
			@limit = limit.kind_of(Integer) ? limit : 25
		end
		def limit
			@limit
		end
		def timeout=(timeout)
			@timeout = timeout.kind_of(Integer) ? timeout : 60
		end
		def timeout
			@timeout
		end
		def retry_limit=(count)
			@retry_limit = count.kind_of(Integer) ? count : 3
		end
		def retry_limit
			@retry_limit
		end
		def app_name
			@app_name
		end
		def app_name=(name = "Application")
			@app_name = name
		end
	end
end 
