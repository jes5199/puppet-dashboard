module Registry
  @registry = Hash.new do |registry, feature_name|
    registry[feature_name] = Hash.new do |hooks, hook_name|
      hooks[hook_name] = Hash.new
    end
  end

  def self.each_hook( feature_name, hook_name )
    hook = @registry[feature_name][hook_name]
    hook.keys.sort.each do |callback_name|
      yield( hook[callback_name] )
    end
  end

  def self.add_hook( feature_name, hook_name, callback_name, value )
    @registry[feature_name][hook_name][callback_name] = value
  end
end
