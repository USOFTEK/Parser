require_relative "spec_helper"

describe Mycra::Queue do
	let :queue_opts do
		{ 
			:amqp			=> 'amqp://guest:guest@localhost:5672', 
			:vhost			=> '/',
			:durable		=> true,
			:heartbeat		=> 2,
			:exchange		=> 'mycra',
			:exchange_type	=> :direct,
		}
	end
	describe "#initialize" do
		it "should create new bunny queue" do
			queue = Mycra::Queue.new("mycra_test", queue_opts)
			expect(queue).to be_an(Mycra::Queue)
		end
	end
	describe "#subscribe" do
		let :message do
			{:task => "start"}.to_json
		end
		let :publisher do
			Mycra::Queue.new("mycra_sender", queue_opts)
		end
		it "should publish and receive messages" do
			q = Mycra::Queue.new("mycra_test", queue_opts)
			q.subscribe("mycra_queue_test") do |hdr, mdt, msg|
				expect(msg).to eq(message)
			end
			publisher.publish(message, "mycra_queue_test")
			q.unsubscribe
		end
	end
end