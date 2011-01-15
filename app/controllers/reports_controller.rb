class ReportsController < InheritedResources::Base
  belongs_to :node, :optional => true, :finder => :find_by_url!
  protect_from_forgery :except => [:create, :upload]

  before_filter :raise_if_enable_read_only_mode, :only => [:new, :edit, :update, :destroy]
  before_filter :handle_raw_post, :only => [:create, :upload]

  def index
    index! do |success,failure|
      success.html do
        if params[:kind] == "inspect"
          @reports = paginate_scope Report.inspections
        else
          @reports = paginate_scope Report.applies
        end
      end
    end
  end

  def create
    if SETTINGS.disable_legacy_report_upload_url
      render :text => "Access Denied, this url has been disabled, try /reports/upload", :status => 403
    else
      upload
    end
  end

  def upload
    begin
      Report.create_from_yaml(params[:report][:report])
      render :text => "Report successfully uploaded"
    rescue => e
      error_text = "ERROR! ReportsController#upload failed:"
      Rails.logger.debug error_text
      Rails.logger.debug e.message
      render :text => "#{error_text} #{e.message}", :status => 406
    end
  end

  def diff
    @my_report = Report.find(params[:id])
    @baseline_report = Report.find(params[:baseline_id])
    @diff = @baseline_report.diff(@my_report)
  end

  def diff_summary
    diff
    @resources = {}
    @diff.each do |resource, differences|
      if ! differences.empty?
        @resources[resource] = :failure
      else
        @resources[resource] = :pass
      end
    end
  end

  def make_baseline
    report = Report.find( params[:id] )
    report.baseline!
    redirect_to report
  end

  def search
    if params[:search_all_inspect_reports]
      inspected_resources = ResourceStatus.inspections
    else
      inspected_resources = ResourceStatus.latest_inspections
    end
    inspected_resources = inspected_resources.order("reports.time DESC")

 #  if params[:file_title].present? and params[:file_content].present?
 #    @files = inspected_resources.by_file_title(params[:file_title])
 #    if params[:content_match] == "negative"
 #      @files = @files.without_file_content(params[:file_content])
 #    else
 #      @files = @files.by_file_content(params[:file_content])
 #    end

    if ! params[:file_title]
      @files = nil
      return
    elsif params[:file_title].present?
      @files = inspected_resources.by_file_title(params[:file_title])
    else
      @files = inspected_resources
    end
    
    @md5s = []
    @sets = { nil => [] }
    @files.each do |r|
      content = r.events.find_by_property("content").previous_value rescue nil
      if content and ! @sets.has_key? content
        @md5s << content
        @sets[content] = []
      end
      @sets[content] << r
    end

    #@files = paginate_scope @files
  end

  private

  def collection
    get_collection_ivar || set_collection_ivar(
      request.format == :html ? 
        paginate_scope(end_of_association_chain) : 
        end_of_association_chain
    )
  end

  def handle_raw_post
    report = params[:report]
    params[:report] = {}
    case report
    when String
      params[:report][:report] = report
    when nil
      params[:report][:report] = request.raw_post
    when Hash
      params[:report] = report
    end
  end

end
