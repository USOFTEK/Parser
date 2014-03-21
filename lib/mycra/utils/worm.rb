require "capybara"
require "capybara-webkit"

module Mycra
	module Worm
		def start_session(job)
			self.register_thread
			Capybara.run_server = false
			Capybara.app = "MYC"
			Capybara.app_host = "http://market.yandex.ua"
			if Mycra::Config.get[:use_proxy]
				@proxy = Mycra::Proxy.where(:status => true).all.sample
				set_proxy @proxy
			else
				Capybara.default_driver		= :webkit
				Capybara.javascript_driver	= :webkit
				@session = Capybara::Session.new(:webkit)
			end
			Mycra::Logger.create_session Thread.current_object_id.to_s(36), job
		end
		def destroy_session(job)
			Mycra::Logger.destroy_session Thread.current_object_id.to_s(36), job
		end
		def wait_for_ajax
			Timeout.timeout(Capybara.default_wait_time) do
				active = @session.evaluate_script('$.active')
				active = @session.evaluate_script('$.active') until active == 0
			end
		end
		def set_proxy current
			@proxy = Mycra::Proxy.where(:status => true).nor(:host => current[:host], :port => current[:port]).all.sample
			Capybara.register_driver :webkit do |app|
				browser = Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new).tap do |browser|
					browser.set_proxy :host => proxy[:host], :port => proxy[:port], :user => proxy[:user], :pass => proxy[:pass]
				end
				Capybara::Webkit::Driver.new(app, :browser => browser, :ignore_ssl_errors => true)
			end
			Capybara.default_driver		= :webkit
			Capybara.javascript_driver	= :webkit
			@session = Capybara::Session.new(:webkit)
		end
		def visit_path(path, referer)
			error = 0
			@session.driver.header "Referer", referer
			begin
				@session.visit(path)
			rescue => we
				error += 1
				retry unless error >= Mycra::Config.get[:page_error]
			ensure
				Mycra::Proxy.broken_proxy(@proxy) if error >= Mycra::Config.get[:page_error] && @session.status_code.scan(/^(4|5){1}\d{2}$/i)
			end
		end
		private
		def register_thread
			Mycra::Logger.find_or_create_by(:name => Thread.current.object_id.to_s(36)).update_attribute(:status => true)
		end
		def unregister_session
			Mycra::Logger.where(:name => Thread.current.object_id.to_s(36)).destroy
		end
	end
end