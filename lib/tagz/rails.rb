if defined?(Rails)
  #_ = ActionView, ActionView::Base, ActionController, ActionController::Base
  #ActionView::Base.send(:include, Tagz.globally)
  #ActionController::Base.send(:include, Tagz)

  unloadable(Tagz)
  Tagz.xml_mode!
end
