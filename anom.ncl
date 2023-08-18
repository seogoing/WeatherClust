begin
FILE  = "./DATA/ERA5_zg850_KST_day_20052013_MJJAS"
VAR = "zg850"

f = addfile(FILE+".nc","r")
utc = cd_calendar(f->time,0)
mm = utc(:,1)
dd = utc(:,2)
lat = f->latitude
lon = f->longitude
data = f->z
data = data/9.8 ;Change unit

output = new(dimsizes(data),float,data@_FillValue)

do i = 0, count_unique_values(mm*100+dd)-1
	time_ind = ind(mm.eq.mm(i) .and. dd.eq.dd(i))
    print(mm(i)+"-"+dd(i))
	dayclim = dim_avg_n_Wrap(data(time_ind,:,:),0)
	output(time_ind,:,:) = data(time_ind,:,:) - conform_dims(dimsizes(data(time_ind,:,:)),dayclim,(/1,2/))
    delete([/dayclim,time_ind/])
end do

copy_VarAtts(data,output)
output@units = "m"
copy_VarCoords(data,output)

system("rm -rf  "+FILE+"_anom.nc")
of = addfile(FILE+"_anom.nc","c")
of->$VAR$ = output
end
