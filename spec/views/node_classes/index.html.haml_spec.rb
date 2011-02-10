require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_classes/index.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      view.stubs(:action_name => 'index')
      @node_classes = [ NodeClass.generate!, NodeClass.generate! ].paginate
      render
    end

    it "has node class items" do
      rendered.should have_selector('.node_class', :count => @node_classes.size)
      rendered.should have_selector("#node_class_#{@node_classes.last.id}")
    end

    it { rendered.should have_selector('form.search') }
  end
end
