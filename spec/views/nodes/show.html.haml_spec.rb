require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/nodes/show.html.haml" do
  include NodesHelper

  describe "successful render" do
    before(:each) do
      @report = Report.generate!
      @node = @report.node
      render
    end

    it { rendered.should have_selector('h2', :content => @node.name) }
  end
end
