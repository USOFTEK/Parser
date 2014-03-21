require "mycra/utils/worm"

require "sneakers"
require "json"

module Mycra
	class Parser
		include Mycra::Worm
		include Sneakers::Worker

		from_queue "parser",
			:threads => 50,
			:prefetch => 1,
			:timeout_job_after => 5

		def work(msg)
			message = Hash.new
			JSON.parse(msg).map { |k,v| message[k.to_sym] = v }
			if self.respond_to?(message[:task])
				self.start_session "parser"
				if message.has_key?(:params)
					self.send message[:task].to_sym, message[:params]
				else
					self.send message[:task]
				end
			end
		end
		private
		def start
			until Mycra::Model::Link.where(:status => false).count > 0
				Mycra::Model::Link.where(:status => false).first.with_lock { |current|
					product = Hash.new

					visit_path(current.href, current.referer)

				    product[:name] = @session.find(".b-page-title_type_model").text.strip
				    breadcrumbs = @session.all(".b-breadcrumbs__link span").to_a
				    product[:prototype] = breadcrumbs.first.text.strip
				    product[:taxon] = breadcrumbs.last.text.strip
				    product[:images] = Array.new

				    @session.all(".b-model-pictures img").each { |img|
				      size = FastImage.size(img[:src])
				      type = FastImage.type(img[:src])
				      product[:images].push({:name => File.basename(img[:src]), :size => File.size(img[:src]), :type => type, :content => open(img[:src]).read, :width => size.shift, :height => size.pop})
				    }

				    # Visit characteristics page
				    @session.find_link("Характеристики").hover
				    @session.find_link("Характеристики").click

				    product[:table] = parse_characteristics

				    # Visit modifications page
				    @session.find_link("Все модификации").hover
				    @session.find_link("Все модификации").click

				    product[:modifications] = Array.new
				    if @session.has_css?(".b-configurations__description a")
				      modifications = Array.new
				      @session.all(".b-configurations__description a").each { |mod|
				        modifications.push({:name => mod.text.strip, :referer => @session.current_url, :href => mod[:href]})
				      }
				      modifications.each { |mdf|
				        modific = parse_product_modifications mdf[:href], mdf[:referer]
				        product[:modifications].push(modific)
				      }
				    end
				    @queue.exchange.publish({:task => "save_product", :params => product}.to_json, :routing_key => "parser") unless product.empty?
				    current.status = true
				    current.save
				}
			end
		end
		def save_product(data)
			return unless product.empty?
			# find or create product
			taxon = Taxon.find_or_create_by(:name => data[:taxon])
			product = taxon.products.find_or_create_by(:name => data[:name])
			# pack images
			data[:images].each { |image|
				begin
					image = product.asset.find_or_create_by(:name => image[:name])
					image.type = image[:type]
					image.attachment_width = image[:width]
					image.attachment_height = image[:height]
					image.data = image[:content]
					image.attachment_file_size = image[:size]
					image.attachment_content_type = "image/#{image[:type]}"
					image.save
				end unless product.assets.where(:name => image[:name]).exists?
			} unless data[:images].empty?
			data[:table].each { |row|
				row[:options].each { |option|
					property = product.properties.find_or_create_by(:name => option[:name])
					option[:options].each { |option_type|
						property.option_types.find_or_create_by(:name => option_type[:name]).option_values.find_or_create_by(:value => option_type[:value], :presentation => option_type[:value])
					}
				}
			}
			data[:modifications].each { |var|
				modification = product.childrens.find_or_create_by(:name => var[:name])
				var[:table].each { |prop|
					property = modification.properties.find_or_create_by(:name => prop[:name])
					prop[:options].each { |co|
						property.option_values.find_or_create_by(:name => co[:name]).option_values.find_or_create_by(:value => co[:value])
					}
				}
			}
		end
		def parse_product_modifications url, referer
			visit_path(url)

			product[:name] = @session.find(".b-page-title_type_model").text.strip

			@session.find_link("Характеристики").hover
			@session.find_link("Характеристики").click

 			table = parse_characteristics
			table
		end
		def parse_characteristics
			table = Array.new
			@session.all("table.b-properties tbody tr").each { |row|
				if row.has_css?("td")
					table.last[:options].push({:name => row.find("th").text.strip, :value => row.find("td").text.strip})
				else
					table.push({:name => row.text.strip, :options => Array.new})
				end
			}
		end
	end
end