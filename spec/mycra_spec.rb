require_relative "spec_helper"

describe Mycra do
	describe 'self' do
		it "should have default configurations" do
			expect(Mycra::Config).to eq(Mycra::DEFAULTS)
		end
		it "should be configurable" do
			db_path = "some new DB path"
			Mycra.configure { |c|
				c[:database] = db_path
			}
			expect(Mycra::Config[:database]).to eq(db_path)
		end
	end
	describe "#reset!" do
		before do
			path = "some path"
			Mycra.configure { |c| c[:database] = path }
		end
		it "shoud reset configurations to default" do
			Mycra.reset!
			expect(Mycra::Config[:database]).not_to eq("some path")
		end
	end
	describe "#get_ready!" do
		Mycra.get_ready!
	end
	describe "#configure_workers!" do
		let :sneakers_opts do
			{
			:daemonize		=> true,
			:log			=> STDOUT,
			:ack			=> true,
			:amqp			=> 'amqp://guest:guest@localhost:5672',
			:vhost			=> '/',
			:durable		=> true,
			:heartbeet		=> 2,
			:exchange		=> 'mycra',
			:exchange_type	=> :direct,
			:handler		=> Mycra::Handler::ExponentialRetry
		}
		end
		before do
			Mycra.configure_sneakers!(sneakers_opts)
		end
		it "should demonize sneakers" do
			expect(Sneakers::Config[:daemonize]).to eq(sneakers_opts[:daemonize])
		end
		it "should setup logger" do
			expect(Sneakers::Config[:log]).to eq(sneakers_opts[:log])
		end
		it "should setup acknowlege" do
			expect(Sneakers::Config[:ack]).to eq(sneakers_opts[:ack])
		end
		it "should setup rabbitmq" do
			expect(Sneakers::Config[:amqp]).to eq(sneakers_opts[:amqp])
		end
		it "should setup rabbitmq vhost" do
			expect(Sneakers::Config[:vhost]).to eq(sneakers_opts[:vhost])
		end
		it "should setup rabbitmq durable" do
			expect(Sneakers::Config[:durable]).to eq(sneakers_opts[:durable])
		end
		it "should setup rabbitmq heartbeet" do
			expect(Sneakers::Config[:heartbeet]).to eq(sneakers_opts[:heartbeet])
		end
		it "should setup rabbitmq exchange" do
			expect(Sneakers::Config[:exchange]).to eq(sneakers_opts[:exchange])
		end
		it "should setup rabbitmq exchange type" do
			expect(Sneakers::Config[:exchange_type]).to eq(sneakers_opts[:exchange_type])
		end
		it "should setup sneakers handler" do
			expect(Sneakers::Config[:handler]).to eq(sneakers_opts[:handler])
		end
	end
	describe "#setup_sneakers_runner!" do
		let :workers do
			[Class.new, Class.new]
		end
		it "should setup workers" do
			Mycra.setup_sneakers_runner!(workers)
			expect(Mycra.sneakers).not_to eq(false) 
		end
	end
	describe "#setup_messanger" do
		
	end
	describe "#setup_proxy" do
		before do
			Mycra.configure :use_proxy => true, :proxy_path => "unknown"
		end
		it "shoud unset use of proxy" do
			Mycra.setup_proxy
			expect(Mycra::Config[:use_proxy]).to eq(false)
		end
	end
end