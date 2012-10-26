#require 'rubygems'
#require 'capybara'
#require 'capybara/dsl'
#require 'capybara/rspec'
#require 'capybara-webkit'
#require 'launchy'


#require 'capybara_helper'


def screenshot
  require 'capybara/util/save_and_open_page'
  now = Time.now
  p = "/#{now.strftime('%Y-%m-%d-%H-%M-%S')}-#{rand}"
  Capybara.save_page body, "#{p}.html"
  path = Rails.root.join("#{Capybara.save_and_open_page_path}" "#{p}.png").to_s
  page.driver.render path
  Launchy.open path
end

def verify_alert_message(msg, &block)
  page.evaluate_script %Q|  window.alert = function(msg) {
                              window.alert_message = msg;
                              return true;
                            }; |
  yield
  page.evaluate_script("window.alert_message").should eq(msg)
ensure
  page.evaluate_script("window.alert_message = null)")
end

def js_confirm(accept=true)
  page.evaluate_script "window.original_confirm = window.confirm"
  page.evaluate_script "window.confirm = function(msg) { return #{!!accept}; }"
  yield
ensure
  page.evaluate_script "window.confirm = window.original_confirm"
end

def wait_until_ajax_done(wait_time=Capybara.default_wait_time)
  wait_until wait_time do
    page.evaluate_script('$.active') == 0
  end
end


RSpec.configure do |config|
  config.before(:each) do
  Capybara.default_wait_time = 10
  Capybara.default_driver = :webkit
  Capybara.javascript_driver = :webkit
  Capybara.run_server = false
  Capybara.app_host = ENV["TEST_SERVER"] || 'http://localhost:3000'
  puts ' using remote server : '+ Capybara.app_host.to_s
  end
end



def should_have_no_errors
  page.should_not have_content "something went wrong"
  page.should_not have_css ".alert-error"
end

def find_answer concept
  puts 'find_answer : ' + concept.to_s
  msg = "cannot fill in, no text field, text area or password field with data-short_name= '#{concept}' found"
  page.find(:css,("[data-short-name='#{concept}']") , :message => msg)
end

def fill_answer concept,value
  if (value.nil? || value.to_s.blank?)
    puts ' skip filling concept ' + concept
    return false
  end
  puts ' fill_answer ' + concept + ' : ' + value.to_s
  node = find_answer(concept)
  name = node[:name]

  if node["disabled"] == true
    puts 'disabled :' + node[:disabled]+' visible? ' + node.visible?.to_s + ' : ' + node["data-short-name"]
    wait_until { node.visible? }
  end

  if name.include? "date_value"
    #date field
    date = Date.parse(value)
    puts 'set date : year : '  + date.year.to_s + ' month : '  + date.month.to_s + ' day : ' + date.day.to_s
    node.set(date.day.to_s)
    find(:css,("[name='#{name.sub("3i","2i")}']")).set(date.month.to_s)
    find(:css,("[name='#{name.sub("3i","1i")}']")).set(date.year.to_s)
  end
  #puts 'disabled ' + node[:disabled] +' : '+  ' : ' + node["data-short-name"]

  node.set(value)
  node.trigger("change")
end

def fill_answers options
  options.each_key do  |key|
    fill_answer key,options[key]
  end
end

def populate_patient_assessments options
  options.each do |option|
    populate_patient_assessment option
  end
end

def populate_patient_assessment options
  visit '/'
  click_link "Pre-op assessment"
  should_have_no_errors
  page.should have_content "Please answer these questions"
  fill_answers options[:answers]
  select_random_values
  click_button "Submit"
  page.should have_content "Assessment was successfully created"
end

def populate_generated_patient_assessment index,professional
  visit '/'
  puts ' populate_generated_patient_assessment ' + index.to_s
  click_link "Pre-op assessment"
  should_have_no_errors
  page.should have_content "All information is Confidential"
  select_random_values
  find_and_set_anesthetist professional
  populate_text_fields index
  click_button "Submit"
  page.should have_content "Thank you, your assessment has been sent to your doctor"
end


def login prof
  visit '/'
  puts prof.to_s
  click_link "Login"
  fill_in "user_email", {with: prof['email']}
  fill_in "user_password", {with: prof['password']}
  click_button "Sign in"
  should_have_no_errors
end

def create_patient options
  login options[:professionals][0]
  click_link 'Patients'
  should_have_no_errors
  patients = options[:patients]
  patients.each do |pat|
    puts 'create patients ' + pat.to_s
    click_link 'New Patient'
    fill_answers  pat[:answers]
    select_random_values
    click_button 'Create Patient'
    page.should have_content "Patient was successfully created"
    click_link 'Back'
  end
end


def create_generated_patient number,professional
    login professional
    click_link 'Patients'
    should_have_no_errors
    puts 'create generated patient ' + number .to_s
    click_link 'New Patient'
    select_random_values
    find_and_set_anesthetist professional
    populate_text_fields number
    click_button 'Create Patient'
    page.should have_content "Patient was successfully created"
    click_link "Logout"
    page.should have_content "Signed out successfully"
end

def last_page?
  links = page.all(:css,'.pagination li')
  links[links.size-2][:class].include?"active"
end

def assign_assessments professional
  login professional
  click_link 'Patients'
  should_have_no_errors
  # pages loop
  begin
    rows = page.all(:xpath,'//table/tbody/tr')
    rows.each do |row|
       puts row.text
       puts row.find(:xpath, ".//td").text
       link_str = row.find(:xpath, ".//td").text.to_s
       click_link(link_str )
       page.should have_content "Patient information"
       puts 'at patient'
       click_link("Find patient assessment")
       puts 'Find patient assessment'
       assessments = page.all(:xpath,'//table/tbody/tr')
      if assessments.size == 1
        puts 'Find patient assessment'
        click_link "Show"
        click_link "Assign"
        page.should have_content "Assessment assigned."
        click_link "Back"
      else
        puts " possible match not found : "  + assessments.size.to_s
      end
       screenshot
       click_link "Patient List"
    end
    click_link "Next "
    puts 'next page'
  end until last_page?
end




def create_generated_patients options
    professional = options[:professionals][0]
    login professional
    click_link 'Patients'
    should_have_no_errors
    100.times do |i|
      number = (10000 * i + rand(10000))
      puts 'create generated patient ' + number .to_s
      click_link 'New Patient'
      select_random_values
      find_and_set_anesthetist professional
      populate_text_fields number
      click_button 'Create Patient'
      page.should have_content "Patient was successfully created"
      click_link 'Back'
    end
end

def populate_text_fields index=0
  inputs = page.all(:css,'input.question')
  inputs.each do |node|
    #fill_in(node, with:(node["data-short-name"] + "_" + index.to_s))
    puts ' setting question : ' + node["data-short-name"] + 'with ' + node["data-short-name"] + "_" + index.to_s
    node.set(node["data-short-name"] + "_" + index.to_s)
    puts ' question : ' + node["data-short-name"] + 'set value : ' + node[:value]
  end

  inputs = page.all(:css,'textarea.question_details')
    inputs.each do |node|
      #fill_in(node, with:(node["data-short-name"] + "_" + index.to_s))
      puts ' setting question : ' + node["data-short-name"] + 'with ' + node["data-short-name"] + "_" + index.to_s
      node.set(node["data-short-name"] + "_" + index.to_s + ' : here are some details.')
      puts ' question : ' + node["data-short-name"] + 'set value : ' + node[:value]
    end
end

def find_and_set_anesthetist professional
  puts 'select professional ' + professional.to_s
  xpath = '//select[@data-short-name="anesthetist"]/option[text()="' + professional["name"] + '"]'
  puts 'xpath : ' + xpath
  selects = page.find(:xpath,xpath)
  selects.select_option

end

def select_random_values
  selects = page.all(:xpath,'//select')
  selects.each do |node|
    if (node.value.blank? && node.visible?)
      puts 'populating ' + node[:name]
      select_random_option(node)
      puts 'node[value] ' + node[:value]
    end
  end
end

def select_random_option(node)
  puts 'select_random_option ' + node["value"]
  options = node.all(:xpath,".//option")
  # we not choosing first option as it is blank
  if node[:name].include? "3i"
    index = 1 + rand(26)
  else
    index = 1 + rand(options.size-1)
  end

  puts 'selecting  '  + options[index]["value"]
  options[index].select_option
end
