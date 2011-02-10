require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/_report.html.haml" do
  include ReportsHelper

  it "should not fail" do
    assigns[:report] = @report = Report.generate!
    template.stubs(:resource => @report)
    render :locals => {:report => @report}, :template => 'reports/_report.html.haml'
  end
end
