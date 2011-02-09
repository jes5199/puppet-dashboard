class Status
  attr_reader :changed, :unchanged, :failed, :total, :start
  def initialize(datum)
    @changed = datum["changed"].to_i
    @unchanged = datum["unchanged"].to_i
    @failed = datum["failed"].to_i
    @total = datum["total"].to_i
    @start = Time.zone.parse(datum["start"])
  end

  def self.latest(options={})
    by_interval(options.merge(:limit => 1)).first
  end

  def self.recent(options={})
    by_interval options.merge(:start => 1.hour.ago)
  end

  # Returns an array of Statuses by date for either a :node, or :nodes or all nodes in the system.
  #
  # Options:
  # * :node => Node to return Statuses for.
  # * :nodes => Nodes to return Statuses for.
  # * :start => Start Time of the range to query.
  # * :limit => Limit the number of records to return.
  def self.by_interval(options={})
    return [] if options[:nodes] && options[:nodes].empty?
    interval = 1.day

    # WARNING: This uses the local server time, regardless of what is set in the Rails config.
    # This should be changed once we have a user-friendly settings file, or can get the browser
    # time zone to this method.
    offset = Time.zone.now.utc_offset
    offset_timestamp = "UNIX_TIMESTAMP(time) + #{offset}"
    date = "DATE(FROM_UNIXTIME(#{offset_timestamp}))"

    sql = <<-SQL
      SELECT
        COUNT(*)                      as total,
        SUM(CASE status when "unchanged" then 1 else 0 end) as unchanged,
        SUM(CASE status when "changed" then 1 else 0 end) as changed,
        SUM(CASE status when "failed" then 1 else 0 end) as failed,
        #{date}                       as start
      FROM reports
    SQL

    sql << "WHERE kind = 'apply' "
    sql << "AND time >= \"#{options[:start].getutc.to_s(:db)}\"\n" if options[:start]
    sql << "AND node_id = #{options[:node].id} " if options[:node]
    sql << "AND node_id IN (#{options[:nodes].map(&:id).join(',')})\n" if options[:nodes].present?
    sql << "GROUP BY #{date}\n"
    sql << "ORDER BY time ASC\n"
    sql << "LIMIT #{options[:limit]}" if options[:limit]

    return execute(sql)
  end

  def self.within_daily_run_history(options={})
    self.by_interval( options.merge( :start => SETTINGS.daily_run_history_length.days.ago, :limit => SETTINGS.daily_run_history_length ) )
  end

  def self.runtime
    Report.all(:limit => 20, :order => 'time DESC').map{|r| r.metrics[:time][:total]}
  end

  private

  def self.execute(sql)
    results = ActiveRecord::Base.connection.execute(sql)

    results.map do |row|
      datum = {}
      results.fields.zip(row).each{|key, value| datum[key] = value }
      new(datum)
    end

  end
end
