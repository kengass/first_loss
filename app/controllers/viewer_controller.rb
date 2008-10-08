class ViewerController < ApplicationController
def index
    @funds = {'asarx'=>'Ultra Short Mortgage Fund','aultx'=>'Ultra Short Fund','ascpx'=>'Intermediate Mortgage Fund','asitx'=>'Short U.S. Government Fund','asmtx'=>'U.S. Government Mortgage Fund',}
    @titles = Security.find(:all,:conditions=> ["date = ?",@vdate.vdate],:select=>"title, id",:order =>"cusip")

  if params[:fund] or params[:id] or params[:ids]
    @results =[] 
    @list=[]
    params.keys.each do |ke|
    case ke
      when "fund"
        @pagetitle = "<h3>All securities for #{@funds[params[:fund]]} for #{@vdate.vdate}</h3>"
        unless @list = Security.find(:all, :conditions=> ["fund = ? AND date = ? ",params[:fund],@vdate.vdate],:order =>"cusip")
               flash[:notice] = 'There are no securities for that date.'              
        end
      when "ids"
        params[:ids].scan(/\w/).each do |i|
          @list << Security.find_by_id(i)               
        end
        @pagetitle = "<h3>The following secirities have been added to the databse</h3>"

      when "id"
       unless  @list << Security.find_by_id(params[:id])
        @pagetitle = "<h3>Report for security #{@list[0].cusip} as of #{@list[0].date}</h3>"      
          flash[:notice] = 'Specified security does not exist.'     
       else
         @list<<"WTF?"
       end
    end 
    end#params each do ke
    @list.each do |l|
      res = {}#clear the temp storage variable
      unless res['sec'] = l
               flash[:notice] = 'Specified security does not exist.'              
        end
        
         #build F_loss dates
        if fldates = Fldate.find(:all, :conditions=> ["security_id = ?",l.id],:order =>"severity, cdr")
        @sev=[]
        cdr=[]
        rdata ={}    
        #get unique 
       fldates.each do |d|
          @sev << d.severity
          cdr << d.cdr
        end
       res['sev']= @sev.uniq
       res['cdr']= cdr.uniq
      #BUILD TABLE
          set={}       
        @sev.each do |se|
          cdr.each do |cd|
            if record = Fldate.find_by_security_id_and_cdr_and_severity(l.id,cd,se)
              set[cd]=record.f_loss
            end
          end
          rdata[se]=set
          set ={}
        end
        res['rdata']=rdata
        else
          flash[:notice] = 'Specified security does not have first loss dates.'              
        end
        @results << res  
      end#list.each do 
  end#if params
end
  
def build_date
end

end
