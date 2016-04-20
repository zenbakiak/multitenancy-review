module I18nHelperMethods
  include I18n

  def t *args
    I18n.t(*args)
  end

end

RSpec.configure do |config|
  config.include I18nHelperMethods 
end

