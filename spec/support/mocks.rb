
def mock_watir_browser
  watir_browser = instance_double('Watir::Browser')
  allow(watir_browser).to receive(:is_a?).with(anything()).and_return(false)
  allow(watir_browser).to receive(:is_a?).with(Watir::Browser).and_return(true)
  allow(watir_browser).to receive(:goto).with(anything()).and_return(true)
  allow(watir_browser).to receive(:text_field).with(anything()).and_return(nil)
  watir_browser
end

def mock_login_page(nav_to_page = true)
  login_page = object_double(AdminModule::Pages::LoginPage.new(mock_watir_browser, nav_to_page))
  allow(login_page).to receive(:login_as)#.with(anything()).and_return(nil)
  allow(login_page).to receive(:logout)#.with(anything()).and_return(nil)
  login_page
end

def mock_guidelines_page(nav_to_page = true)
  gdls_page = object_double(AdminModule::Pages::GuidelinesPage.new(mock_watir_browser, nav_to_page))
end

def mock_page_factory_with_method(meth, obj)
  page_factory = instance_double('AdminModule::PageFactory')
  allow(page_factory).to receive(meth).and_return(obj)
  page_factory
end

def mock_page_factory
  obj = MockPageFactory.new
  obj.login_page = mock_login_page
  obj.guidelines_page = mock_guidelines_page
  obj
end

class MockPageFactory

  attr_writer :login_page
  attr_writer :guidelines_page

  def login_page(nav_to_page = true)
    @login_page ||= mock_login_page(nav_to_page)
  end

  def guidelines_page(nav_to_page = true)
    @guidelines_page ||= mock_guidelines_page(nav_to_page)
  end
end

def mock_client()
  mock_client = object_double(AdminModule::Client.new)

  allow(mock_client).to receive(:login).with(anything, anything).and_return(nil)
  allow(mock_client).to receive(:logout).and_return(nil)
  allow(mock_client).to receive(:quit).and_return(nil)
  allow(mock_client).to receive(:guideline).and_return(mock_guideline)
  #allow(mock_client).to receive(:write_layout).with(anything, anything).and_return(true)
  #allow(mock_client).to receive(:write_layout_class).with(anything, anything).and_return(true)
  #allow(mock_client).to receive(:write_delegate_class).with(anything, anything).and_return(true)

  mock_client
end

def mock_guideline(pg_factory)
  mock_guideline = object_double(AdminModule::Guideline.new(pg_factory))

  allow(mock_guideline).to receive(:deploy).and_return(nil)
  allow(mock_guideline).to receive(:deploy_file).and_return(nil)
  allow(mock_guideline).to receive(:version).and_return(nil)

  mock_guideline
end

