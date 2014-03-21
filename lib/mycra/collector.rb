require "mycra/utils/worm"

require "sneakers"
require "json"

module Mycra
	class Collector
		include Mycra::Worm
		include Sneakers::Worker
		from_queue	"collector",
			:threads	=> 10,
			:prefetch	=> 1,
			:timeout_job_after => 0

		def work(msg)
			message = Hash.new
			JSON.parse(msg).map { |k,v| message[k.to_sym] = v }
			if self.respond_to?(message[:task])
				self.start_session "collection"
				if message.has_key?(:params)
					self.send message[:task].to_sym, message[:params]
				else
					self.send message[:task]
				end
			end
		end
		private
		def restart
			Mycra::Model::Link.all.update_attribute(:status => false)
		end
		def start
			visit_path("/index-full.xml", Capybara.app_host)
			@session.all(".guru").each { |blk|
				link = blk.all("a").first
				info = {:name => link.text.strip, :md5 => Digest::MD5.hexdigest(link.text.strip), :href => link[:href]}
				Mycra::Model::Category.parse_category(info) if info[:href].scan /^\/[\w?\/\.=]+/i
			}
			Mycra::Model::Category.roots.each { |category|
				@queue.exchange.publish({:task => "collect_categories", :params => { :id => category.id, :name => category.name } }.to_json, :routing_key => "collector")
			}
		end
		def collect_categories(params)
			current = Category.where(:_id => params["id"], :name => params["name"])
			visit_path(current.href, "/index-full.xml")
			@session.all(".guru").each { |blk|
				link = blk.all("a").first
				current.children.find_or_create_by(:name => link.text.strip).update_attributes(:href => link[:href], :reference => Digest::MD5.hexdigest(link.text.strip)) if link[:href].scan /^\/[\w?\/\.=]+/i
			} if @session.has_css?(".guru")
			current.children.each { |subcategory|
				@queue.exchange.publish({:task => "collect_categories", :params => {:id => subcategory.id, :name => subcategory.name } }.to_json, :routing_key => "collector")
			} if current.children.count > 0
		end
		def collect_products
			Mycra::Model::Category.roots.each { |root|
				@queue.publish({:task => "category_products", :params => {:id => root.id, :name => root.name} }.to_json, :routing_key => "collector")
			} if Mycra::Model::Link.count > 0
		end
		def category_products(params)
			current = Mycra::Model::Category.where(:_id => params["id"], :name => params["name"]).first
			visit_path(current.href, "/index-full.xml")
			@session.find(".body .black").hover
			@session.find(".body .black").click
			self.recursive_collection(current)
		end
		private
		def recursive_collection(category)
			blocks = @session.all(".b-offers_type_guru_mix")
			blocks.each { |blk|
				current = blk.first("a.b-offers__name")
				link = Mycra::Model::Link.find_or_create_by(:reference => Digest::MD5.hexdigest(current.text.strip))
				link.name = current.text.strip
				link.category = category.id
				link.href = current[:href]
				link.referer = @session.current_path
				link.save!
			}
			if @session.has_css?(".b-pager__next")
				@session.find(".b-pager__next").hover
				@session.find(".b-pager__next").click
				recursive_collection(category)
			else
				self.destroy_session("collection")
		    end 
		end
	end
end