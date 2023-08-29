;Define Extreme Rainfall Event using Automated Surface Observing System (ASOS) data
begin

VAR = "pr"
SEASON = "MJJAS"

SYR = 2005
EYR = 2013

num_occurstn = 4
pptn_percent = 0.1

;====READ ASOS rainfall data===================================
if(SEASON.eq."MJJAS") then
    SMON = 5
    EMON = 9
end if

IFILE 		= addfile("DATA/ASOS_rn_KST_day_"+SYR+EYR+".nc","r")
raw_time 	= IFILE->time
lat 		= IFILE->lat
lon 		= IFILE->lon
stn 		= IFILE->stn

raw_utc  	= cd_calendar(raw_time,0)
raw_timeind = ind(raw_utc(:,0).ge.SYR .and. raw_utc(:,0).le.EYR .and. \
                  raw_utc(:,1).ge.SMON .and. raw_utc(:,1).le.EMON)

DATA 		= IFILE->rn(raw_timeind,:) ;Dimension: [time(3287), station(66)]

time 		= DATA&time
ntime 		= dimsizes(time)
nstn 		= dimsizes(DATA(0,:))
delete([/raw_time,raw_utc,raw_timeind/])

;====Define ERE=================================================
;Calculate 90th percentile daily rainfall in 2005-2013 MJJAS period for each ASOS station
data2 		= DATA
qsortind 	= dim_pqsort_n(data2,-2,0)
st90th 		= data2(toint(dimsizes(data2(:,0))*pptn_percent),:) 
st90th2 	= conform_dims(dimsizes(data2),st90th,(/1/))
extreme 	= where(DATA.ge.st90th2,1,0)
delete([/data2,qsortind/])

;ERE is defined as the day when there are more than four stations that record more than the 90th percentile daily rainfall
utc = cd_calendar(time,-2)
ERE_date = new(ntime,integer)
ERE_stn = new((/ntime,nstn/),integer)
ii = 0
do itime = 0, ntime-1
    imsi = extreme(itime,:)
    if(num(imsi.eq.1).ge.num_occurstn) then
        ERE_date(ii) = toint(utc(itime))
        ERE_stn(ii,:) = imsi
        ii = ii+1
    end if
    delete(imsi)
end do

ERE_date := ERE_date(:ii-1)
ERE_stn := ERE_stn(:ii-1,:)

ERE_date!0 = "time"
ERE_stn!0 = "time"
ERE_stn!1 = "stn"

;====Write ERE data==============================================
OFILE = "./OUT/ERE_date_"+VAR+"_ASOS_KST_"+SYR+EYR+"_"+SEASON
system("rm -rf  "+OFILE+".nc")
ncdf = addfile(OFILE+".nc", "c")
ncdf->date = ERE_date
ncdf->loc = ERE_stn
ncdf->lat = lat
ncdf->lon = lon

end
