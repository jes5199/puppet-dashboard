require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/nodes/new.html.haml" do
  include NodesHelper

  describe "successful render" do
    before :each do
      @node = Node.spawn
      params[:controller] = "nodes"
      render
    end

    it { rendered.should have_selector('form[method=post]', :action => nodes_path) }
  end
end
