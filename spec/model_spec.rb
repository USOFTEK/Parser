require_relative "spec_helper"

describe Mycra::Model::Category do
	it "should validate presence of name" do
		should have_fields(:name, :href)
	end
end