require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/edit' do
  before :each do
    assigns[:node] = @node = Node.generate!
    params[:id] = @node.id
  end

  def do_render
    params[:controller] = "nodes"
    render :template => 'nodes/edit'
  end

  describe 'when errors are available' do
    it 'should display errors if name is blank' do
      @node.name = ''
      @node.valid?
      do_render
      rendered.should have_selector('div.errors')
    end
  end

  describe 'when no errors are available' do
    it 'should not display error messages' do
      do_render
      rendered.should_not have_selector('div.errors')
    end
  end

  it 'should have a form for editing the node' do
    do_render
    rendered.should have_selector('form', :id => "edit_node_#{@node.id}")
  end

  describe 'for the node edit form' do
    it 'should post to the update node action' do
      do_render
      rendered.should have_selector('form', :id => "edit_node_#{@node.id}", :method => 'post', :action => node_path(@node))
    end

    it 'should set the form method to PUT' do
      do_render
      rendered.should have_selector('form', :id => "edit_node_#{@node.id}") do |form|
        form.should have_selector('input', :name => '_method', :value => 'put')
      end
    end

    it 'should have a name input' do
      do_render
      rendered.should have_selector('form', :id => "edit_node_#{@node.id}") do |form|
        form.should have_selector('input', :type => 'text', :name => 'node[name]')
      end
    end

    it 'should populate the name input' do
      @node.name = 'Test Node'
      do_render
      rendered.should have_selector('form', :id => "edit_node_#{@node.id}") do |form|
        form.should have_selector('input', :name => 'node[name]', :value => @node.name)
      end
    end

    it 'should have a description input' do
      do_render
      rendered.should have_selector('form', :id => "edit_node_#{@node.id}") do |form|
        form.should have_selector('textarea', :name => 'node[description]')
      end
    end

    it 'should populate the description input' do
      @node.description = 'Test Description'
      do_render
      rendered.should have_selector('form', :id => "edit_node_#{@node.id}") do |form|
        form.should have_selector('textarea', :name => 'node[description]', :content => @node.description)
      end
    end
  end

  describe 'editing interface' do
    describe 'for classes' do
      before :each do
        @classes = Array.new(6) { NodeClass.generate! }
        @node.node_classes << @classes[0..2]
      end

      it 'should provide a means to edit the associated classes when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)

        do_render
        rendered.should have_selector('input#node_class_ids')
      end

      it 'should not provide a means to edit the associated classes when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)

        do_render
        rendered.should_not have_selector('input#node_class_ids')
      end

      it 'should show the associated classes when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)
        do_render

        rendered.should have_selector('#tokenizer') do
          struct = get_json_struct_for_token_list('#node_class_ids')
          struct.should have(3).items

          (0..2).each do |idx|
            struct.should include({"id" => @classes[idx].id, "name" => @classes[idx].name})
          end
        end
      end

      it 'should not show the associated classes when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
        do_render

        rendered.should_not have_selector('#node_class_ids')
      end
    end

    describe 'for groups' do
      before :each do
        @groups = Array.new(6) {NodeGroup.generate! }
        @node.node_groups << @groups[0..3]
      end

      it 'should show the associated groups when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)
        do_render

        rendered.should have_selector('#tokenizer') do
          struct = get_json_struct_for_token_list('#node_group_ids')
          struct.should have(4).items

          (0..3).each do |idx|
            struct.should include({"id" => @groups[idx].id, "name" => @groups[idx].name})
          end
        end
      end

      it 'should not show associated groups when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
        do_render

        rendered.should_not have_selector('#node_group_ids')
      end
    end

    def get_json_struct_for_token_list(selector)
      json = rendered[/'#{selector}'.+?prePopulate: (\[.*?\])/m, 1]
      ActiveSupport::JSON.decode(json)
    end
  end

  it 'should link to view the node' do
    do_render
    rendered.should have_selector('a', :href => node_path(@node))
  end
end
