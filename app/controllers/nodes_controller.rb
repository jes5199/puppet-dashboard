class NodesController < InheritedResources::Base
  belongs_to :node_class, :optional => true
  belongs_to :node_group, :optional => true
  respond_to :html, :yaml, :json
  before_filter :raise_unless_using_external_node_classification, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :create, :update, :destroy]

  layout lambda {|c| c.request.xhr? ? false : 'application' }

  def index
    raise NodeClassificationDisabledError.new if !SETTINGS.use_external_node_classification and request.format == :yaml
    scoped_index :unhidden
  end

  def successful
    redirect_to nodes_path(:current => true.to_s, :successful => true.to_s)
  end

  def failed
    redirect_to nodes_path(:current => true.to_s, :successful => false.to_s)
  end

  def unreported
    scoped_index :unhidden, :unreported
  end

  def no_longer_reporting
    scoped_index :unhidden, :no_longer_reporting
  end

  def hidden
    scoped_index :hidden
  end

  def search
    index! do |format|
      format.html {
        @search_params = params['search_params'] || []
        @search_params.delete_if {|param| param.values.any?(&:blank?)}
        nodes = @search_params.empty? ? [] : Node.find_from_inventory_search(@search_params)
        set_collection_ivar(nodes)
        render :inventory_search
      }
    end
  end

  def show
    begin
      raise NodeClassificationDisabledError.new if !SETTINGS.use_external_node_classification and request.format == :yaml
      @node = resource
      respond_to do |format|
        format.yaml { render :text => @node.to_yaml, :content_type => 'application/x-yaml' }
        format.json { render :text => JSON.parse(@node.to_json)["node"].to_json, :content_type => 'application/x-json' }
        format.html { render }
      end
    rescue ActiveRecord::RecordNotFound => e
      raise e unless request.format == :yaml
      node = {'classes' => []}
      render :text => node.to_yaml, :content_type => 'application/x-yaml'
    rescue ParameterConflictError => e
      raise e unless request.format == :yaml
      render :text => "Node \"#{resource.name}\" has conflicting parameter(s): #{resource.errors.on(:parameters).to_a.to_sentence}", :content_type => 'text/plain', :status => 500
    rescue NodeClassificationDisabledError => e
      render :text => "Node classification has been disabled", :content_type => 'text/plain', :status => 403
    end
  end

  def hide
    respond_to do |format|
      resource.hidden = true
      resource.save!

      format.html { redirect_to node_path(resource) }
    end
  end

  def unhide
    respond_to do |format|
      resource.hidden = false
      resource.save!

      format.html { redirect_to node_path(resource) }
    end
  end

  def facts
    respond_to do |format|
      format.html {
        begin
          render :partial => 'nodes/facts', :locals => {:node => resource, :facts => resource.facts}
        rescue => e
          render :text => "Could not retrieve facts from inventory service: #{e.message}"
        end
      }
    end
  end

  # TODO: routing currently can't handle nested resources due to node's id
  # requirements
  def reports
    @node = resource
    @reports = params[:kind] == "inspect" ? @node.reports.inspections : @node.reports.applies
    respond_to do |format|
      format.html { @reports = paginate_scope(@reports); render 'reports/index' }
    end
  end

  protected

  def resource
    node = get_resource_ivar
    return node if node

    node ||= end_of_association_chain.find(params[:id]) rescue nil
    node ||= end_of_association_chain.find_by_name!(params[:id])

    set_resource_ivar(node)
  end

  # Render the index using the +scope_name+ (e.g. :successful for Node.successful).
  def scoped_index(*scope_names)
    index! do |format|
      scope = end_of_association_chain
      if params[:q]
        scope = scope.search(params[:q])
      end
      scope_names.each do |scope_name|
        scope = scope.send(scope_name)
      end
      if params[:current].present? or params[:successful].present?
        scope = scope.by_currentness_and_successfulness(params[:current] == "true", params[:successful] == "true")
      end
      set_collection_ivar(scope.with_last_report.by_report_date)

      format.html { render :index }
      format.yaml { render :text => collection.to_yaml, :content_type => 'application/x-yaml' }
      format.json { render :text => JSON.parse(collection.to_json).map{|j| j["node"]}.to_json, :content_type => 'application/x-json' }
    end
  end
end
