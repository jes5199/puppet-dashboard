require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/_search.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before { render }

    it { rendered.should have_selector('form.search') }
  end
end
