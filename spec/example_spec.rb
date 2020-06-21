# frozen_string_literal: true

require "spec_helper"

RSpec.describe "example test" do
  describe "2 + 2" do
    subject { 2 + 2 }

    it "equals to 4" do
      expect(subject).to eq(4)
    end
  end
end
