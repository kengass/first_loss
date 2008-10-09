class ParseController < ApplicationController
  
  #Security columns
    #cusip
    #fund,
    #date
    #moodys
    #s_p
    #fitch
    #ce_orig,
    #ce_cur,
    #title
    #qtr_cdr,
    #qtr_severity,
    #forclosure_reo
    #delinq_30_60_90

 # require "fileutils"
  

  def index
    @dir = "public/intex/"
    @funds = {'asarx'=>'Ultra Short Mortgage Fund','aultx'=>'Ultra Short Fund','ascpx'=>'Intermediate Mortgage Fund','asitx'=>'Short U.S. Government Fund','asmtx'=>'U.S. Government Mortgage Fund',}
    @list = {}
    @exist = []
    @record_date= Security.find(:first, :conditions => "title = 'record_date'", :select=>"date") 
    
    #get directories    
    @funds.each do |key,value|
      #if value[-3]=="xls"
        @list[key]= list_files("#{@dir}#{key}")
        @list[key].each do |v|

          if Security.find(:first, :conditions => "filename = '#{v.chomp(".xls").chop}'") 
            @exist << v.chomp(".xls").chop
          end#if
        end#@each key do
     # end#if value[-3]
    end#@funds each do
   end
  
 def list_files(dir)
    Dir.new(dir).entries.sort.delete_if { |x| ! (x =~ /xls$/) }
 end
   
 def parse_it
 params.delete("authenticity_token")
 params.delete("action")
 params.delete("controller")
 
 params.each do |key,value|
  parse(value,key.chop)
 end
 end
 
  def parse(flname,fnd)  
     xsh= "public/intex/" + fnd + "/" + flname
     
    @parsed_file = Excel.new(xsh)     
    @wbtest = []
    id_list = []

    iter = 0#counter
    @results = []#holds objects
    @security = Security.new
    
    
      if @parsed_file.sheets.each do |wbook|
        unless wbook == "Sheet1"
          #set switched and counters
          stat_switch = 'on' #switch for laoding characteristics
          date_switch = 'off'#switch for loading first_loss dates
          f_loss_switch = 'off'#switch for loading first_loss dates
          
          
          #reset variables
          writecol =''
          datecol = ''
          @parsed_file.default_sheet = wbook
          #load results

          @fldate = Fldate.new
          #get security  before loop        
          if 2.upto(@parsed_file.last_row) do |line|
           1.upto(10) do |ce|
            label  = @parsed_file.cell(line,ce)
            value = @parsed_file.cell(line,ce+1) 

            #===================================================== get the security          
             if @parsed_file.default_sheet == @parsed_file.sheets.first 
               @security.title = @parsed_file.cell(1,'A')
               @security.fund = fnd
               @security.filename = flname.chomp(".xls").chop
               
                #==============================Determine Fund
                #look for data in the first two columns
                 if stat_switch == 'on'                
                    case label
                      when "30,60,90 Delinq:"
                       @security.delinq_30_60_90 = value
                      when "CUSIP"
                       @security.cusip = value             
                      when "Curr Moody's"
                       @security.moodys = value
                      when "Curr Fitch"
                       @security.fitch = value
                      when "Curr S&P"
                       @security.s_p = value             
                      when "Latest update:"
                       @security.date = value   
                      when "Orig Support (%)"
                       @security.ce_orig = value   
                      when "Cur Support (%)"
                       @security.ce_cur = value 
                      when "Fclsr,REO:"
                       @security.forclosure_reo = value                                  
                    end#case                       
                 end#if statswitch   
               end#securities loader (if first sheet)
               
              #===================================================== switcheroo              
              if label== "Assumptions"
                   stat_switch = "off"
                   f_loss_switch = "on" 
              end
              
              #===================================================== get the cdr & severity
              if f_loss_switch == 'on' 
               case label       
                when "Default Rate"
                   @fldate.cdr = value.gsub(' cdr','')
                when "Default Severity"
                   @fldate.severity = value                                      
                when "Princ Writedown"
                  writecol = ce
                  @fldate.writedown = @parsed_file.cell(line+1,ce)
                when "Principal"
                  @fldate.principal = @parsed_file.cell(line+1,ce)
                when "Date"
                  datecol = ce#grab collunm containing dates
                when "0"
                  if @parsed_file.cell(line+1,ce)=="1" and @parsed_file.cell(line+2,ce)=="2"
                    date_switch = "on"#set begining of date array
                   # f_loss_switch = 'off'#you are done with everyting but dates so why look
                  end
               end#case label

              #===================================================== date switch                              
              #now the line has to be in the date array and the column needs to be the writedown column
              if date_switch == "on" and ce == writecol
                unless @parsed_file.cell(line,ce) == 0 or @parsed_file.cell(line,ce) == ""
                  @fldate.f_loss = @parsed_file.cell(line,datecol)
                  date_switch = 'off'#if a first loss date is displayed quit
                end#if                
              end#if date switch = "on"
            end#if floss switch = "on"
           
            end #column each do
          end#line do
          else
             flash[:notice] = 'There was a problem cycling through lines.' 
             exit
          end#if line do
          @results << @fldate
                   iter+=1 
          end#unless wbook != sheet1 
       end#workbook do
      else#if each.do sheets
         flash[:notice] = 'There was a problem cycling through sheets.'
        exit               
      end#if each.do sheets

    #===================================================== save it all
    if @ex = Security.find_by_cusip_and_fund_and_date(@security.cusip,@security.fund,@security.date)
      @ex.update_attributes(@security.attributes)
                id_list << @ex.id#load the list
      @results.each do |r| 
       r.security_id = @ex.id
          r.save
          
          archive(flname,fnd)
          
      end  #do
    else @security.save
       @results.each do |r| 
        r.security_id = @security.id
          r.save
          
          archive(flname,fnd)
          
          id_list << @security.id#load the list for display       
       end#results each do
    end#if security exists-update  
      redirect_to "?ids=#{id_list.join(',')}"
  end#index
  
def archive(flname2,fnd2) 
   ofile = "public/intex/" + fnd2 + "/" + flname2
   nfile = "public/intex/archive/" + fnd2 + "/" + flname2
   FileUtils.mv ofile, nfile
       
end  
end
