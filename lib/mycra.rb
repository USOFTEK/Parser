require "mycra/version"
require "mycra/collector"
require "mycra/parser"
require "mycra/informer"
require	"mycra/utils/handler"
require "mycra/queue"
Dir.glob("#{File.dirname(File.expand_path(__FILE__))}/mycra/model/*.rb").each { |model| require "#{model}"}

require "sneakers"
require "sneakers/runner"
require "bunny"
require "eventmachine"
require "json"
require 'capybara'
require 'capybara-webkit'
require 'capybara/dsl'
require "yaml"
require "logger"

module Mycra
	DEFAULTS = {
		# sneakers
		:sneakers => {
			:daemonize		=> true,
			:ack			=> true,
			:amqp			=> 'amqp://guest:guest@localhost:5672',
			:vhost			=> '/',
			:durable		=> true,
			:heartbeat		=> 2,
			:workers 		=> 3,
			:exchange		=> 'mycra',
			:exchange_type	=> :direct,
			:log			=> STDOUT,
			:handler		=> Mycra::Handler::ExponentialRetry
		},
		# local
		:collet_delay	=> 5 * 60,
		:parse_delay	=> 10 * 60,
		:log_delay		=> 10,
		:database		=> "mycra/config/database.yml",
		:db_deploy		=> :production,
		:page_error		=> 5,
		:use_proxy		=> false,
		:workers 		=> [Mycra::Collector, Mycra::Parser, Mycra::Informer],
		:parser_threads	=> 20,
		:queue_name		=> "mycra_queue",
		:proxy_path		=> "Full path to proxy list (yml or csv)"
	}.freeze
	# Configs
	Config = DEFAULTS.dup
	def self.configure(opts = {})
		if block_given?
			yield Config
		else
			Config.merge!(opts)
		end
	end
	# Setup configurations and modules
	def self.get_ready!
		@connection = false
		@sneakers = false
		@messanger = false
		configure_database!(Config[:database], Config[:db_deploy])
		setup_proxy
		configure_sneakers!(Config[:sneakers])
		setup_sneakers_runner!(Config[:workers])
		setup_messanger
	end
	def self.reset!
		Config.merge!(DEFAULTS)
		@sneakers = false
		@connection = false
		@messanger = false
		configure_database!(Config[:database], Config[:db_deploy])
		configure_sneakers!(Config[:sneakers])
		setup_sneakers_runner!(Config[:sneakers])
		setup_messanger
	end
	# Run system
	def self.start(&block)
		EM.run {
			instance_eval(&block)
		}
	end
	# Configure sneakers runner
	def self.setup_sneakers_runner!(workers)
		@sneakers = Sneakers::Runner.new(workers)
	end
	# Configure database
	def self.configure_database!(path, deploy)
		Mongoid.load!(path, deploy.to_sym)
	end
	# Configure Sneakers
	def self.configure_sneakers!(opts)
		Sneakers.configure(opts)
	end
	# Run sneakers
	def self.run_workers
		EM.defer { @sneakers.run }
	end
	# Run product collector
	def self.start_collector
		EM.add_periodic_timer(Config[:collet_delay]) {
			publish({:task => "start"}.to_json, "collector")
			publish({:task => "collect_products"}.to_json, "collector")
		}
	end
	# Run product parser
	def self.start_parser
		EM.add_periodic_timer(Config[:parse_delay]) {
			publish({:task => "start"}.to_json, "parser")
		}
	end
	def self.start_logger
		EM.add_periodic_timer(Config[:log_delay]) {
			publish({:task => "status", :params => {:routing_key => Config[:info_queue]}}.to_json, "informer")
		}
	end
	# Publishing messages
	def self.publish(message, routing)
		setup_messanger unless @connection
		@messanger.publish(message, routing)
	end
	def self.restart_collection
		publish({:task => "restart"}.to_json, "collector")
	end
	# Subscribe to queue
	def self.subscribe(&callback)
		@messanger.subscribe(routing, callback)
	end
	def self.setup_messanger
		@messanger = Mycra::Queue.new(Config[:queue_name], Config[:sneakers])
	end
	def self.messanger
		@messanger || false
	end
	def self.sneakers
		@sneakers || false
	end
	def self.setup_proxy
		if Config[:use_proxy] && File.exists?(Config[:proxy_path])
			Mycra::Model::Proxy.send("load_from_#{File.basename(Config[:proxy_path])[-3,3]}".to_sym, Config[:proxy_path])
		else
			Config[:use_proxy] = false
		end
	end
end
