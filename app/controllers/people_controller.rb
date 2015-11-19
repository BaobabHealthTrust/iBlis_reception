class PeopleController < ApplicationController
  def find
  end

  def family_names
    search("family_name", params[:search_string])
  end
  
  def given_names
    search("given_name", params[:search_string])
  end
  
  def search(field_name, search_string)
    i = 0 if field_name == 'given_name'
    i = 1 if field_name == 'family_name'
    names = Patient.where("name LIKE (?)", "%#{search_string}").limit(20).map {|pat| pat.name.split(' ')[i] }
    render :text => "<li>" + names.uniq.map{|n| n } .join("</li><li>") + "</li>"
  end

  def addresses
    names = Patient.where("address LIKE (?)", "#{params[:search_string]}%").limit(20).map {|pat| pat.address }
    render :text => "<li>" + names.uniq.map{|n| n } .join("</li><li>") + "</li>"
  end

  def people_search_results
    given_name = params[:name]['given_name'] ; family_name = params[:name]['family_name']
    @patients = Patient.where("name LIKE (?) AND gender = ?", 
      "%#{given_name} #{family_name}",params[:gender]).limit(20)

    render :layout => false
  end

  def create
    Patient.create(:name => "#{params[:person]['names']['given_name']} #{params[:person]['names']['family_name']}",
      :created_by => User.current.id,:address => params[:person]['addresses']['physical_address'],
      :phone_number => params[:cell_phone_number],:gender => params[:gender],:patient_number => (Patient.count + 1),
      :dob => calDOB(params),:external_patient_number => "T-#{rand(10000).to_s.rjust(9,'0')}")

    redirect_to '/'
  end

  private

  def calDOB(params)
    if params[:person]['birth_year'] == "Unknown"
      birthdate = Date.new(Date.today.year - params[:person]["age_estimate"].to_i, 7, 1)
    else
      year = params[:person]["birth_year"].to_i
      month = params[:person]["birth_month"]
      day = params[:person]["birth_day"].to_i

      month_i = (month || 0).to_i
      month_i = Date::MONTHNAMES.index(month) if month_i == 0 || month_i.blank?
      month_i = Date::ABBR_MONTHNAMES.index(month) if month_i == 0 || month_i.blank?

      if month_i == 0 || month == "Unknown"
        birthdate = Date.new(year.to_i,7,1)
      elsif day.blank? || day == "Unknown" || day == 0
        birthdate = Date.new(year.to_i,month_i,15)
      else
        birthdate = Date.new(year.to_i,month_i,day.to_i)
      end
    end

    return birthdate
  end

end
